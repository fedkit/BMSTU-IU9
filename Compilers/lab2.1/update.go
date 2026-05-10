package main

import "fmt"

func square(x int) int {
	fmt.Printf("square %d\n", x*x)
	return x * x
}

func increment(y int) (z int) {
	z = y + 1
	fmt.Printf("increment %d\n", z)
	return
}

func abs(x int) int {
	if x < 0 {
		fmt.Printf("abs %d\n", -x)
		return -x
	}
	fmt.Printf("abs %d\n", x)
	return x
}

func firstPositive(nums []int) int {
	for _, v := range nums {
		if v > 0 {
			fmt.Printf("firstPositive %d\n", v)
			return v
		}
	}
	fmt.Printf("firstPositive %d\n", -1)
	return -1
}

func complexCalc(a, b int) int {
	fmt.Printf("complexCalc %d\n", a*a+2*a*b+b*b)
	return a*a + 2*a*b + b*b
}

func max(a, b int) (m int) {
	if a > b {
		m = a
		fmt.Printf("max %d\n", m)
		return
	}
	m = b
	fmt.Printf("max %d\n", m)
	return
}

func concat(a, b string) string {
	return a + b
}

func swap(a, b int) (int, int) {
	return b, a
}

func main() {
	fmt.Println(square(5))
	fmt.Println(increment(10))
	fmt.Println(abs(-7))
	fmt.Println(firstPositive([]int{-3, -2, 0, 5, 8}))
	fmt.Println(complexCalc(2, 3))
	fmt.Println(max(4, 9))
	fmt.Println(concat("go", "lang"))
	fmt.Println(swap(1, 2))
}
