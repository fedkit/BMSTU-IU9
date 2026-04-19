error id: file://<WORKSPACE>/Main.scala:
file://<WORKSPACE>/Main.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -adaneStack.
	 -scala/Predef.adaneStack.
offset: 2183
uri: file://<WORKSPACE>/Main.scala
text:
```scala
trait NumericKadane[T] {
  def plus(a: T, b: T): T
  def zero: T
  def compare(a: T, b: T): Int
}

object NumericKadane {

  implicit object IntKadane extends NumericKadane[Int] {
    def plus(a: Int, b: Int): Int = a + b
    def zero: Int = 0
    def compare(a: Int, b: Int): Int = a.compare(b)
  }

  implicit object DoubleKadane extends NumericKadane[Double] {
    def plus(a: Double, b: Double): Double = a + b
    def zero: Double = 0.0
    def compare(a: Double, b: Double): Int = a.compare(b)
  }
}

// узел стека (хранит предвычисления)
case class Node[T](
  value: T,
  prev: Option[Node[T]],
  sum: Option[Any],     // только для числовых (будет None для non-numeric)
  best: Option[Any]     // Kadane max sum prefix (тоже optional)
)

class KadaneStack[T] {

  private var head: Option[Node[T]] = None

  def empty: Boolean = head.isEmpty

  // обычный push для любого T
  def push(x: T): KadaneStack[T] = {
    val node = Node(x, head, None, None)
    head = Some(node)
    this
  }

  def pop(): Option[T] = {
    head match {
      case None => None
      case Some(node) =>
        head = node.prev
        Some(node.value)
    }
  }

  def top: Option[T] = head.map(_.value)

  // KadaneStack как обычный стек для любых типов
  def toList: List[T] = {
    def loop(n: Option[Node[T]], acc: List[T]): List[T] = n match {
      case None => acc
      case Some(node) => loop(node.prev, node.value :: acc)
    }
    loop(head, Nil)
  }

  // maxSum НЕ здесь — он в companion object
}

object KadaneStack {

  // maxSum доступен ТОЛЬКО для числовых типов
  def maxSum[T](stack: KadaneStack[T])(implicit ev: NumericKadane[T]): T = {
    val list = stack.toList

    var current = ev.zero
    var best = ev.zero

    for (x <- list) {
      current = ev.plus(x, current)
      if (ev.compare(current, best) > 0)
        best = current
      if (ev.compare(current, ev.zero) < 0)
        current = ev.zero
    }

    best
  }
}

object Main {
  def main(args: Array[String]): Unit = {

    val stackInt = new KadaneStack[Int]()
    stackInt.push(1)
    stackInt.push(-2)
    stackInt.push(3)
    stackInt.push(4)
    stackInt.push(-1)

    println("Int stack maxSum: " +adan@@eStack.maxSum(stackInt))

    val stackStr = new KadaneStack[String]()
    stackStr.push("A")
    stackStr.push("B")
    stackStr.push("C")

    println(stackStr.top.get)

  }
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 