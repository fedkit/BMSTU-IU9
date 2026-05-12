object Main {

  trait Term
  case class Var(name: String) extends Term
  case class App(fun: Term, arg: Term) extends Term
  case class Lam(param: String, body: Term) extends Term

  def show(t: Term): String = t match {
    case Var(n)    => n
    case App(f, a) => s"(${show(f)} ${show(a)})"
    case Lam(x, b) => s"(λ$x.${show(b)})"
  }

  def freeVars(t: Term): Set[String] = t match {
    case Var(n)    => Set(n)
    case App(f, a) => freeVars(f) ++ freeVars(a)
    case Lam(x, b) => freeVars(b) - x
  }

  def substitute(t: Term, x: String, s: Term): Term = t match {
    case Var(n)    => if (n == x) s else t
    case App(f, a) => App(substitute(f, x, s), substitute(a, x, s))
    case Lam(v, b) => if (v == x) t else Lam(v, substitute(b, x, s))
  }

  def noCapture(body: Term, x: String, y: String): Boolean = {
    def check(t: Term, bound: Set[String]): Boolean = t match {
      case Var(n)    => if (n == x) !bound.contains(y) else true
      case App(f, a) => check(f, bound) && check(a, bound)
      case Lam(v, b) => if (v == x) true else check(b, bound + v)
    }
    check(body, Set.empty)
  }

  def optimize(t: Term): Term = t match {
    case Var(_) => t

    case App(Lam(x, body), Var(y)) if noCapture(body, x, y) =>
      optimize(substitute(body, x, Var(y)))

    case Lam(x, App(f, Var(y))) if x == y && !freeVars(f).contains(x) =>
      optimize(f)

    case App(f, a) =>
      val f2 = optimize(f)
      val a2 = optimize(a)
      (f2, a2) match {
        case (Lam(x, body), Var(y)) if noCapture(body, x, y) =>
          optimize(substitute(body, x, Var(y)))
        case _ => App(f2, a2)
      }

    case Lam(x, body) =>
      val body2 = optimize(body)
      body2 match {
        case App(f, Var(y)) if x == y && !freeVars(f).contains(x) =>
          optimize(f)
        case _ => Lam(x, body2)
      }
  }

  def main(args: Array[String]): Unit = {
    // (λx.x) y  ->  y
    val t1 = App(Lam("x", Var("x")), Var("y"))
    println(s"β:         ${show(t1)}  ->  ${show(optimize(t1))}")

    // λx.(f x)  ->  f
    val t2 = Lam("x", App(Var("f"), Var("x")))
    println(s"η:         ${show(t2)}  ->  ${show(optimize(t2))}")

    // (λx.λy.x) y  
    val t3 = App(Lam("x", Lam("y", Var("x"))), Var("y"))
    println(s"no β:      ${show(t3)}  ->  ${show(optimize(t3))}")

    // (λf.λx.(f x)) g  ->  λx.(g x)  →  g
    val t4 = App(Lam("f", Lam("x", App(Var("f"), Var("x")))), Var("g"))
    println(s"β + η:     ${show(t4)}  ->  ${show(optimize(t4))}")

    // (λx.(x x)) y  ->  (y y)
    val t5 = App(Lam("x", App(Var("x"), Var("x"))), Var("y"))
    println(s"β self:    ${show(t5)}  ->  ${show(optimize(t5))}")
  }
}
