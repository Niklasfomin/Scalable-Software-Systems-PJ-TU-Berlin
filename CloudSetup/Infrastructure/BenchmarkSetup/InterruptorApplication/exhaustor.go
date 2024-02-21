package main

import (
    "fmt"
    "log"
    "math"
    "runtime"
    "sync"
    "time"
)

func fibonacci(n int) int {
    if n <= 1 {
        return n
    }
    return fibonacci(n-1) + fibonacci(n-2)
}

func memoryIntensiveTask(wg *sync.WaitGroup, done <-chan bool) {
    defer wg.Done()
    iterations := 0
    for {
        select {
        case <-done:
            return
        default:
            size := 1000000 
            slice := make([]int, size)
            for i := range slice {
                slice[i] = i
            }
            iterations++
            if iterations % 100 == 0 {
            }
        }
    }
}

func calculatePi(wg *sync.WaitGroup, done <-chan bool) {
    defer wg.Done()
    var pi float64
    iterations := 0
    for {
        pi += math.Pow(-1, float64(iterations)) / (2*float64(iterations) + 1)
        iterations++
        if iterations % 1000000 == 0 {
        }
        select {
        case <-done:
            return
        default:
        }
    }
}

func matrixMultiplication(wg *sync.WaitGroup, done <-chan bool) {
    defer wg.Done()
    const size = 100
    a := make([][]float64, size)
    b := make([][]float64, size)
    c := make([][]float64, size)
    for i := 0; i < size; i++ {
        a[i] = make([]float64, size)
        b[i] = make([]float64, size)
        c[i] = make([]float64, size)
        for j := 0; j < size; j++ {
            a[i][j] = float64(i + j)
            b[i][j] = float64(i - j)
        }
    }
    iterations := 0
    for {
        for i := 0; i < size; i++ {
            for j := 0; j < size; j++ {
                sum := 0.0
                for k := 0; k < size; k++ {
                    sum += a[i][k] * b[k][j]
                }
                c[i][j] = sum
            }
        }
        iterations++
        if iterations % 10 == 0 {
        }
        select {
        case <-done:
            return
        default:
         
        }
    }
}

func memcopy(wg *sync.WaitGroup, done <-chan bool) {
    defer wg.Done()
    const bufferSize = 1024 * 1024 // 1MB buffer
    src := make([]byte, bufferSize)
    dest := make([]byte, bufferSize)
    iterations := 0
    for {
        copy(dest, src)
        iterations++
        if iterations % 10000 == 0 {
        }
        select {
        case <-done:
            return
        default:

        }
    }
}

func main() {
    log.SetFlags(log.LstdFlags | log.Lmicroseconds)
    numCPU := runtime.NumCPU()
    log.Println("Number of CPUs:", numCPU)

    runtime.GOMAXPROCS(numCPU)

    var wg sync.WaitGroup
    done := make(chan bool)

    tasks := []func(*sync.WaitGroup, <-chan bool){calculatePi, matrixMultiplication, memcopy}
    for _, task := range tasks {
        wg.Add(1)
        go task(&wg, done)
    }

    go func() {
        timer := time.NewTicker(1 * time.Second)
        endTime := time.Now().Add(5 * time.Minute)
        for now := range timer.C {
            if now.After(endTime) {
                timer.Stop()
                break
            }
            fmt.Printf("\rInterruptor Application will be running for: %s", endTime.Sub(now).Round(time.Second).String())
        }
        fmt.Println("\nTimer ended, stopping tasks.")
        close(done)
    }()

    wg.Wait()
    fmt.Println("Stress test completed")
}
