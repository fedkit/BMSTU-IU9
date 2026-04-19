error id: file://<WORKSPACE>/Main.scala:_empty_/KadaneStack#empty().
file://<WORKSPACE>/Main.scala
empty definition using pc, found symbol in pc: _empty_/KadaneStack#empty().
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -s1/empty.
	 -s1/empty#
	 -s1/empty().
	 -scala/Predef.s1.empty.
	 -scala/Predef.s1.empty#
	 -scala/Predef.s1.empty().
offset: 86
uri: file://<WORKSPACE>/Main.scala
text:
```scala
case

object Main extends App {

  val s1 = KadaneStack.empty[Int]

  println(s1.empty@@)

  val s2 = s1
    .push(1)
    .push(-2)
    .push(3)
    .push(4)
    .push(-1)

  println(s2.empty)
  println(s2.maxSum)

  val s3 = s2.pop()
  val s4 = s3.pop()

  println(s4.maxSum)
  println(s4.empty)

  val emptyStack = s4.pop().pop().pop().pop()

  println(emptyStack.empty)

  // Double
  val d1 = KadaneStack.empty[Double]

  val d2 = d1
    .push(2.5)
    .push(-1.0)
    .push(3.0)

  println(d2.maxSum)
  println(d2.empty)

  val d3 = d2.pop()
  println(d3.maxSum)

  // String
  val str1 = KadaneStack.empty[String]
    .push("a")
    .push("b")

  println(str1.empty)
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: _empty_/KadaneStack#empty().