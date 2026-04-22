error id: E45E499371C0A848A4F2695FEA3C0527
file://<WORKSPACE>/Main.scala
### java.lang.AssertionError: assertion failed: position error, parent span does not contain child span
parent      = new UnsupportedOperationException(_root_.scala.Predef.???) # -1,
parent span = <655..689>,
child       = _root_.scala.Predef.??? # -1,
child span  = <689..694>

occurred in the presentation compiler.



action parameters:
uri: file://<WORKSPACE>/Main.scala
text:
```scala
class ArranSet private (
    private val isValid: Seq[Int] => Boolean,
    private val elements: Option[Set[Seq[Int]]]
) {

  def in(seq: Seq[Int]): Boolean =
    isValid(seq)

  def +(other: ArranSet): ArranSet = {
    val newElements =
      (this.elements, other.elements) match {
        case (Some(a), Some(b)) => Some(a ++ b)
        case (Some(a), None)    => Some(a)
        case (None, Some(b))    => Some(b)
        case _                  => None
      }

    new ArranSet(
      seq => this.in(seq) || other.in(seq),
      newElements
    )
  }

  def size: Int =
    elements match {
      case Some(set) => set.size
      case None => throw new UnsupportedOperationException(
    }
}

object ArranSet {
  private def generate(k: Int, m: Int): Set[Seq[Int]] =
    (0 to k)
      .toList
      .combinations(m)
      .flatMap(_.permutations)
      .toSet

  private def isValid(k: Int, m: Int)(seq: Seq[Int]): Boolean =
    seq.length == m &&
    seq.distinct.length == m &&
    seq.forall(x => x >= 0 && x <= k)

  def apply(k: Int, m: Int): ArranSet = {
    val elems = generate(k, m)
    new ArranSet(
      isValid(k, m),
      Some(elems)
    )
  }
}

object Main extends App {
  val s1 = ArranSet(4, 3)
  val s2 = ArranSet(3, 2)

  println(s1.in(Seq(0, 1, 2)))
  println(s1.in(Seq(0, 0, 1)))

  println(s1.size)

  val union = s1 + s2
  println(union.in(Seq(1, 2)))
  println(union.in(Seq(2, 3, 4)))
  println(union.size)
}

```


presentation compiler configuration:
Scala version: 3.8.2-bin-nonbootstrapped
Classpath:
<WORKSPACE>/.scala-build/lab2_d5c0a6989e/classes/main [exists ], <HOME>/.cache/coursier/v1/https/repo1.maven.org/maven2/org/scala-lang/scala3-library_3/3.8.2/scala3-library_3-3.8.2.jar [exists ], <HOME>/.cache/coursier/v1/https/repo1.maven.org/maven2/org/scala-lang/scala-library/3.8.2/scala-library-3.8.2.jar [exists ], <HOME>/.cache/coursier/v1/https/repo1.maven.org/maven2/com/sourcegraph/semanticdb-javac/0.10.0/semanticdb-javac-0.10.0.jar [exists ], <WORKSPACE>/.scala-build/lab2_d5c0a6989e/classes/main/META-INF/best-effort [missing ]
Options:
-Xsemanticdb -sourceroot <WORKSPACE> -Ywith-best-effort-tasty




#### Error stacktrace:

```
scala.runtime.Scala3RunTime$.assertFailed(Scala3RunTime.scala:10)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:186)
	dotty.tools.dotc.ast.Positioned.check$1$$anonfun$3(Positioned.scala:216)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	scala.collection.immutable.List.foreach(List.scala:327)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:216)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.check$1$$anonfun$3(Positioned.scala:216)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	scala.collection.immutable.List.foreach(List.scala:327)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:216)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.check$1$$anonfun$3(Positioned.scala:216)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	scala.collection.immutable.List.foreach(List.scala:327)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:216)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:211)
	dotty.tools.dotc.ast.Positioned.check$1$$anonfun$3(Positioned.scala:216)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	scala.collection.immutable.List.foreach(List.scala:327)
	dotty.tools.dotc.ast.Positioned.check$1(Positioned.scala:216)
	dotty.tools.dotc.ast.Positioned.checkPos(Positioned.scala:237)
	dotty.tools.dotc.parsing.Parser.parse$$anonfun$1(ParserPhase.scala:39)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	dotty.tools.dotc.core.Phases$Phase.monitor(Phases.scala:533)
	dotty.tools.dotc.parsing.Parser.parse(ParserPhase.scala:40)
	dotty.tools.dotc.parsing.Parser.$anonfun$2(ParserPhase.scala:52)
	scala.collection.Iterator$$anon$6.hasNext(Iterator.scala:495)
	scala.collection.Iterator$$anon$9.hasNext(Iterator.scala:599)
	scala.collection.immutable.List.prependedAll(List.scala:156)
	scala.collection.immutable.List$.from(List.scala:682)
	scala.collection.immutable.List$.from(List.scala:682)
	scala.collection.IterableOps$WithFilter.map(Iterable.scala:911)
	dotty.tools.dotc.parsing.Parser.runOn(ParserPhase.scala:51)
	dotty.tools.dotc.Run.runPhases$1$$anonfun$1(Run.scala:380)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:15)
	scala.runtime.function.JProcedure1.apply(JProcedure1.java:10)
	scala.collection.ArrayOps$.foreach$extension(ArrayOps.scala:1324)
	dotty.tools.dotc.Run.runPhases$1(Run.scala:373)
	dotty.tools.dotc.Run.compileUnits$$anonfun$1$$anonfun$2(Run.scala:420)
	dotty.tools.dotc.Run.compileUnits$$anonfun$1$$anonfun$adapted$1(Run.scala:420)
	scala.Function0.apply$mcV$sp(Function0.scala:42)
	dotty.tools.dotc.Run.showProgress(Run.scala:482)
	dotty.tools.dotc.Run.compileUnits$$anonfun$1(Run.scala:420)
	dotty.tools.dotc.Run.compileUnits$$anonfun$adapted$1(Run.scala:432)
	dotty.tools.dotc.util.Stats$.maybeMonitored(Stats.scala:69)
	dotty.tools.dotc.Run.compileUnits(Run.scala:432)
	dotty.tools.dotc.Run.compileSources(Run.scala:319)
	dotty.tools.dotc.interactive.InteractiveDriver.run(InteractiveDriver.scala:165)
	dotty.tools.pc.CachingDriver.run(CachingDriver.scala:44)
	dotty.tools.pc.WithCompilationUnit.<init>(WithCompilationUnit.scala:31)
	dotty.tools.pc.SimpleCollector.<init>(PcCollector.scala:357)
	dotty.tools.pc.PcSemanticTokensProvider$Collector$.<init>(PcSemanticTokensProvider.scala:63)
	dotty.tools.pc.PcSemanticTokensProvider.Collector$lzyINIT1(PcSemanticTokensProvider.scala:63)
	dotty.tools.pc.PcSemanticTokensProvider.Collector(PcSemanticTokensProvider.scala:63)
	dotty.tools.pc.PcSemanticTokensProvider.provide(PcSemanticTokensProvider.scala:88)
	dotty.tools.pc.ScalaPresentationCompiler.semanticTokens$$anonfun$1(ScalaPresentationCompiler.scala:158)
	scala.meta.internal.pc.CompilerAccess.withSharedCompiler(CompilerAccess.scala:149)
	scala.meta.internal.pc.CompilerAccess.$anonfun$1(CompilerAccess.scala:93)
	scala.meta.internal.pc.CompilerAccess.onCompilerJobQueue$$anonfun$1(CompilerAccess.scala:210)
	scala.meta.internal.pc.CompilerJobQueue$Job.run(CompilerJobQueue.scala:153)
	java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1136)
	java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635)
	java.base/java.lang.Thread.run(Thread.java:840)
```
#### Short summary: 

java.lang.AssertionError: assertion failed: position error, parent span does not contain child span
parent      = new UnsupportedOperationException(_root_.scala.Predef.???) # -1,
parent span = <655..689>,
child       = _root_.scala.Predef.??? # -1,
child span  = <689..694>