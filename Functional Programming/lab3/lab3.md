% Лабораторная работа № 3 «Обобщённые классы в Scala»
% 15 апреля 2026 г.
% Фёдор Китанин, ИУ9-61Б

# Цель работы
Целью данной работы является приобретение навыков разработки 
обобщённых классов на языке Scala с использованием неявных преобразований типов.

# Индивидуальный вариант
Класс KadaneStack[T], представляющий неизменяемый стек
 с операциями push, pop и empty, реализованный через список.
 В случае, если T — числовой тип, для стека должна быть 
также доступна операция maxSum, возвращающая максимальную 
сумму подряд идущих элементов стека и работающая за константное время.

# Реализация

```scala
trait KadaneStackOps[T] {
  def zero: T
  def plus(a: T, b: T): T
  def compare(a: T, b: T): Int
}

object KadaneStackOps {

  implicit def numericOps[T](implicit num: Numeric[T]): KadaneStackOps[T] =
    new KadaneStackOps[T] {
      def zero: T = num.zero
      def plus(a: T, b: T): T = num.plus(a, b)
      def compare(a: T, b: T): Int = num.compare(a, b)
    }
}

class KadaneStack[T](private val head: KadaneStack.Node[T] = null) {
  def empty: Boolean = head == null

  def push(x: T)(implicit ops: KadaneStackOps[T] = null): KadaneStack[T] = {

    if (ops == null) {
      new KadaneStack(KadaneStack.Node(
        value = x,
        prev = head,
        current = x,
        best = x
      ))
    }
    else {
      val (current, best) =
        if (head == null) {
          (x, x)
        } else {

          val prevCur = head.current

          val newCurrent =
            KadaneStack.max(
              x,
              ops.plus(prevCur, x)
            )(ops)

          val newBest =
            KadaneStack.max(head.best, newCurrent)(ops)

          (newCurrent, newBest)
        }

      new KadaneStack(KadaneStack.Node(
        value = x,
        prev = head,
        current = current,
        best = best
      ))
    }
  }

  def pop: KadaneStack[T] =
    if (head == null)
      throw new Exception("Stack is empty")
    else
      new KadaneStack[T](head.prev)

  def maxSum(implicit ops: KadaneStackOps[T]): T =
    if (head == null) ops.zero
    else head.best

  override def toString: String = {
    var cur = head
    var res = List[T]()

    while (cur != null) {
      res = cur.value :: res
      cur = cur.prev
    }

    s"KadaneStack(${res.mkString(", ")})"
  }
}

object KadaneStack {
  case class Node[T](
    value: T,
    prev: Node[T],
    current: T,
    best: T
  )

  def max[T](a: T, b: T)(implicit ops: KadaneStackOps[T]): T =
    if (ops.compare(a, b) >= 0) a else b

  def create[T]: KadaneStack[T] = new KadaneStack[T]()
}


object Main extends App {

  val s0 = KadaneStack.create[Int]

  val s1 = s0.push(3).push(-2).push(5).push(-1)

  println(s1)
  println(s1.empty)

  println(s1.maxSum)

  val s2 = s1.pop
  println(s2)
  println(s2.maxSum)

  val s3 = s2.push(10)
  println(s3)
  println(s3.maxSum)



  val t0 = KadaneStack.create[String]
  val t1 = t0.push("a").push("b").push("c")

  println(t1)
  println(t1.empty)

  val t2 = t1.pop
  println(t2)

  val t3 = t2.push("d")
  println(t3)

  // println(t1.maxSum) 
}
```

# Вывод
В этой лабораторной работе я приобретёл навыки 
разработки обобщённых классов на языке Scala с использованием неявных преобразований типов.

