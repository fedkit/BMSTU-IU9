error id: file://<WORKSPACE>/Main.scala:scala/Any#asInstanceOf().
file://<WORKSPACE>/Main.scala
empty definition using pc, found symbol in pc: scala/Any#asInstanceOf().
empty definition using semanticdb

found definition using fallback; symbol asInstanceOf
offset: 1576
uri: file://<WORKSPACE>/Main.scala
text:
```scala
trait Addable[T] {
  def add(x: T, y: T): T
}

object Addable {
  implicit object IntAddable extends Addable[Int] {
    def add(x: Int, y: Int): Int = x + y
  }

  implicit object StringAddable extends Addable[String] {
    def add(x: String, y: String): String = x + y
  }
}


class KadaneStack[T](
  val items: List[T],
  val sum: T,
  val pref: T,
  val suff: T,
  val best: T
)(implicit num: Numeric[T] = null) {

  def push(x: T): KadaneStack[T] = {

    if (num == null) {
      new KadaneStack[T](x :: items, null.asInstanceOf[T], null.asInstanceOf[T], null.asInstanceOf[T], null.asInstanceOf[T])
    } else {

      if (items.isEmpty) {
        new KadaneStack[T](List(x), x, x, x, x)
      } else {

        val newSum = num.plus(x, sum)

        val newPref =
          if (num.compare(x, num.plus(x, pref)) > 0) x
          else num.plus(x, pref)

        val newSuff =
          if (num.compare(suff, num.plus(sum, x)) > 0) suff
          else num.plus(sum, x)

        val cross = num.plus(suff, x)

        val newBest =
          List(best, newPref, newSuff, cross).max(num)

        new KadaneStack[T](x :: items, newSum, newPref, newSuff, newBest)
      }
    }
  }

  def pop(): KadaneStack[T] = {
    if (items.isEmpty) this
    else {
      val newItems = items.tail
      KadaneStack.rebuild(newItems)
    }
  }

  def maxSum: Option[T] = {
    if (num == null || items.isEmpty) None
    else Some(best)
  }
}


object KadaneStack {

  def empty[T](implicit num: Numeric[T] = null): KadaneStack[T] =
    new KadaneStack[T](Nil, null.asInstanceOf[T], null.@@asInstanceOf[T], null.asInstanceOf[T], null.asInstanceOf[T])
}


object Main {
  def main(args: Array[String]): Unit = {

    val s1 = KadaneStack.empty[Int]
      .push(3)
      .push(-2)
      .push(5)
      .push(-1)

    println(s1.items)
    println(s1.maxSum)

    val s2 = KadaneStack.empty[Double]
      .push(1.5)
      .push(-2.0)
      .push(3.5)
      .push(2.0)

    println(s2.items)
    println(s2.maxSum)

    val s3 = KadaneStack.empty[String]
      .push("a")
      .push("b")
      .push("c")

    println(s3.items)
    println(s3.maxSum)
  }
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: scala/Any#asInstanceOf().