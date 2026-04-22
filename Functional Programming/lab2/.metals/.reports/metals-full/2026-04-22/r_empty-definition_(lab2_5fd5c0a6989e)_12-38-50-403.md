error id: file://<WORKSPACE>/Main.scala:_empty_/IntSeqSet#
file://<WORKSPACE>/Main.scala
empty definition using pc, found symbol in pc: _empty_/IntSeqSet#
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -IntSeqSet#
	 -scala/Predef.IntSeqSet#
offset: 215
uri: file://<WORKSPACE>/Main.scala
text:
```scala
final class ArranSet private (
    private val containsFunc: Seq[Int] => Boolean,
    private val elements: Option[Set[Seq[Int]]]
) {

  def in(seq: Seq[Int]): Boolean = containsFunc(seq)

  def +(other: ArranSet): @@IntSeqSet = {
    val newElements =
      this.elements.flatMap(a =>
        other.elements.map(b =>
          a union b
        )
      )

    new IntSeqSet(
      seq => this.in(seq) || other.in(seq),
      newElements
    )
  }

  // размер множества
  def size: Int = elements match {
    case Some(set) => set.size
    case None =>
      throw new UnsupportedOperationException("Size is not available")
  }
}

object ArranSet {
  private def fact(n: Int): Int =
    if (n <= 1) 1
    else n * fact(n - 1)

  private def arrangements(k: Int, m: Int): Int =
    fact(k + 1) / fact(k + 1 - m)

  private def generate(k: Int, m: Int): Set[Seq[Int]] = {
    (0 to k)
      .toList
      .combinations(m)
      .flatMap(_.permutations)
      .toSet
  }

  // основной конструктор
  def apply(k: Int, m: Int): ArranSet = {
    val elems = generate(k, m)

    new ArranSet(
      seq =>
        seq.length == m &&
        seq.distinct.length == m &&
        seq.forall(x => x >= 0 && x <= k),
      Some(elems)
    )
  }
}


object Main extends App {
  val s1 = ArranSet(4, 3)
  val s2 = ArranqSet(3, 2)

  println(s1.in(Seq(0, 1, 2))) 
  println(s1.in(Seq(0, 0, 1))) 

  println(s1.size) 

  val union = s1 + s2
  println(union.in(Seq(1, 2)))  
  println(union.in(Seq(2, 3, 4)))
  println(union.size)
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: _empty_/IntSeqSet#