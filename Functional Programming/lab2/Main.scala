class ArranSet private (
    private val isValid: Seq[Int] => Boolean,
    private val elements: Set[Seq[Int]]
) {
  def in(seq: Seq[Int]): Boolean =
    isValid(seq)

  def +(other: ArranSet): ArranSet =
    new ArranSet(
      seq => this.in(seq) || other.in(seq),
      this.elements ++ other.elements
    )

  def size: Int =
    elements.size
}

object ArranSet {
  private def generate(k: Int, m: Int): Set[Seq[Int]] =
    (0 to k)
      .toList
      .combinations(m)
      .flatMap(_.permutations)
      .toSet

  private def isValid(k: Int, m: Int, seq: Seq[Int]): Boolean =
    seq.length == m &&
    seq.distinct.length == m &&
    seq.forall(x => x >= 0 && x <= k)

  def apply(k: Int, m: Int): ArranSet = {
    if (k < 0 || m < 0)
      throw new IllegalArgumentException()

    val elems = generate(k, m)

    new ArranSet(
      seq => isValid(k, m, seq),
      elems
    )
  }
}

object Main extends App {
  val s1 = ArranSet(4, 3)
  val s2 = ArranSet(3, 2)

  println(s1.in(Seq(4, 1, 2)))
  println(s1.in(Seq(1, 1, 1)))

  println(s1.size)

  val union_s = s1 + s2
  println(union_s.in(Seq(1, 2)))
  println(union_s.in(Seq(3, 0, 4)))
  println(union_s.size)
}
