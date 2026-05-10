package main

import "fmt"

func square(x int) int {
	return x * x
}

func increment(y int) (z int) {
	z = y + 1
	return
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

func firstPositive(nums []int) int {
	for _, v := range nums {
		if v > 0 {
			return v
		}
	}
	return -1
}

func complexCalc(a, b int) int {
	return a*a + 2*a*b + b*b
}

func max(a, b int) (m int) {
	if a > b {
		m = a
		return
	}
	m = b
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
