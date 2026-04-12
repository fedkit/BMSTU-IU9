#include "gcc-plugin.h"
#include "plugin-version.h"

#include "coretypes.h"
#include "tree.h"
#include "gimple.h"
#include "gimple-iterator.h"
#include "tree-pass.h"
#include "context.h"
#include "basic-block.h"
#include "function.h"
#include "cfg.h"

#include <cstdio>

int plugin_is_GPL_compatible;

static void indent(int n) {
    for (int i = 0; i < n; i++)
        std::printf(" ");
}

static void print_tree(tree t) {
    switch (TREE_CODE(t)) {

        case SSA_NAME:
            std::printf("ssa_%u", SSA_NAME_VERSION(t));
            break;

        case INTEGER_CST:
            if (tree_fits_shwi_p(t))
                std::printf("%lld", (long long)tree_to_shwi(t));
            else
                std::printf("<int>");
            break;

        case VAR_DECL:
        case PARM_DECL:
            if (DECL_NAME(t))
                std::printf("%s", IDENTIFIER_POINTER(DECL_NAME(t)));
            else
                std::printf("<var>");
            break;

        case ARRAY_REF: {
            tree arr = TREE_OPERAND(t, 0);
            tree idx = TREE_OPERAND(t, 1);

            std::printf("ARRAY_REF(");
            print_tree(arr);
            std::printf(", ");
            print_tree(idx);
            std::printf(")");
            break;
        }

        case MEM_REF: {
            tree ptr = TREE_OPERAND(t, 0);

            std::printf("MEM_REF(");
            print_tree(ptr);

            if (TREE_OPERAND(t, 1)) {
                std::printf(", ");
                print_tree(TREE_OPERAND(t, 1));
            }

            std::printf(")");
            break;
        }

        default:
            std::printf("%s", get_tree_code_name(TREE_CODE(t)));
            break;
    }
}

static const char* op_name(tree_code code) {
    switch (code) {
        case PLUS_EXPR: return "plus_expr";
        case MINUS_EXPR: return "minus_expr";
        case MULT_EXPR: return "mult_expr";
        default: return nullptr;
    }
}

static void print_assign(gassign* s) {
    indent(4);

    tree lhs = gimple_assign_lhs(s);
    tree r1  = gimple_assign_rhs1(s);
    tree r2  = gimple_assign_rhs2(s);

    std::printf("ASSIGN: ");
    print_tree(lhs);
    std::printf(" = ");

    const char* op = op_name(gimple_assign_rhs_code(s));

    if (op && r2) {
        std::printf("%s(", op);
        print_tree(r1);
        std::printf(", ");
        print_tree(r2);
        std::printf(")\n");
    } else {
        print_tree(r1);
        std::printf("\n");
    }
}

static void print_cond(gcond* s) {
    indent(4);

    std::printf("COND: if (");

    print_tree(gimple_cond_lhs(s));

    switch (gimple_cond_code(s)) {
        case LT_EXPR: std::printf(" < "); break;
        case GT_EXPR: std::printf(" > "); break;
        case LE_EXPR: std::printf(" <= "); break;
        case GE_EXPR: std::printf(" >= "); break;
        case EQ_EXPR: std::printf(" == "); break;
        case NE_EXPR: std::printf(" != "); break;
        default: std::printf(" ? "); break;
    }

    print_tree(gimple_cond_rhs(s));

    std::printf(")\n");
}

static void print_call(gcall* s) {
    indent(4);

    tree lhs = gimple_call_lhs(s);
    tree fn  = gimple_call_fn(s);

    std::printf("CALL: ");

    if (lhs) {
        print_tree(lhs);
        std::printf(" = ");
    }

    print_tree(fn);
    std::printf("(");

    int n = gimple_call_num_args(s);
    for (int i = 0; i < n; i++) {
        print_tree(gimple_call_arg(s, i));
        if (i != n - 1)
            std::printf(", ");
    }

    std::printf(")\n");
}

static void print_phi(gphi* p) {
    indent(4);

    std::printf("PHI: ");
    print_tree(gimple_phi_result(p));
    std::printf(" = PHI(");

    int n = gimple_phi_num_args(p);

    for (int i = 0; i < n; i++) {
        tree arg = gimple_phi_arg_def(p, i);
        basic_block bb = gimple_phi_arg_edge(p, i)->src;

        std::printf("[");
        print_tree(arg);
        std::printf(", from BB%d]", bb->index);

        if (i != n - 1)
            std::printf(", ");
    }

    std::printf(")\n");
}

static void print_stmt(gimple* s) {
    switch (gimple_code(s)) {
        case GIMPLE_ASSIGN:
            print_assign(as_a<gassign*>(s));
            break;

        case GIMPLE_COND:
            print_cond(as_a<gcond*>(s));
            break;

        case GIMPLE_CALL:
            print_call(as_a<gcall*>(s));
            break;

        case GIMPLE_RETURN: {
            indent(4);
            std::printf("RETURN ");

            greturn* ret_stmt = as_a<greturn*>(s);
            tree ret = gimple_return_retval(ret_stmt);

            if (ret)
                print_tree(ret);
            else
                std::printf("<void>");

            std::printf("\n");
            break;
        }
        default:
            indent(4);
            std::printf("STMT\n");
            break;
    }
}

static unsigned int run(function* fun) {
    const char* name =
        (fun && fun->decl && DECL_NAME(fun->decl))
        ? IDENTIFIER_POINTER(DECL_NAME(fun->decl))
        : "<unknown>";

    std::printf("\nFunction: %s\n\n", name);

    basic_block bb;

    FOR_ALL_BB_FN(bb, fun) {

        std::printf("BB%d\n", bb->index);

        std::printf("  preds: ");
        edge e;
        edge_iterator ei;
        bool first = true;

        FOR_EACH_EDGE(e, ei, bb->preds) {
            if (!first) std::printf(", ");
            std::printf("BB%d", e->src->index);
            first = false;
        }
        if (first) std::printf("(none)");

        std::printf("\n  succs: ");
        first = true;

        FOR_EACH_EDGE(e, ei, bb->succs) {
            if (!first) std::printf(", ");
            std::printf("BB%d", e->dest->index);
            first = false;
        }
        if (first) std::printf("(none)");

        std::printf("\n  phi nodes:\n");
        for (gphi_iterator pi = gsi_start_phis(bb);
             !gsi_end_p(pi);
             gsi_next(&pi)) {
            print_phi(pi.phi());
        }

        std::printf("  statements:\n");
        for (gimple_stmt_iterator gsi = gsi_start_bb(bb);
             !gsi_end_p(gsi);
             gsi_next(&gsi)) {
            print_stmt(gsi_stmt(gsi));
        }

        std::printf("\n");
    }

    return 0;
}

namespace {

const pass_data my_pass = {
    GIMPLE_PASS,
    "simple-gimple-dump",
    OPTGROUP_NONE,
    TV_NONE,
    PROP_cfg | PROP_ssa,
    0, 0, 0, 0
};

struct my_pass_impl : gimple_opt_pass {
    my_pass_impl(gcc::context* ctx)
        : gimple_opt_pass(my_pass, ctx) {}

    unsigned int execute(function* fun) override {
        return run(fun);
    }
};

}

int plugin_init(struct plugin_name_args* info,
                struct plugin_gcc_version* ver) {

    if (!plugin_default_version_check(ver, &gcc_version)) {
        std::fprintf(stderr, "version mismatch\n");
        return 1;
    }

    register_pass_info pi;
    pi.pass = new my_pass_impl(g);
    pi.reference_pass_name = "ssa";
    pi.ref_pass_instance_number = 1;
    pi.pos_op = PASS_POS_INSERT_AFTER;

    register_callback(info->base_name,
                      PLUGIN_PASS_MANAGER_SETUP,
                      nullptr,
                      &pi);

    return 0;
}