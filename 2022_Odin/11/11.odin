package aoc22

import f "core:fmt"
import   "core:time"

main :: proc() {
    sol1, sol2 : int

    t1 := time.now()
    when ODIN_DEBUG {
	sol1 = pt1_test()
    } else {
	sol1 = pt1()
    }
    t2 := time.now()
    
    f.println("Pt1 Sol:", sol1)
    f.println("Pt1 Time:", time.diff(t1,t2))
    // Returned 182293 in 1.76ms, answer was correct.

    t3 := time.now()
    when ODIN_DEBUG {
	sol2 = pt2_test()
    } else {
	sol2 = pt2()
    }
    t4 := time.now()
    f.println("Pt2 Sol:", sol2)
    f.println("Pt2 Time:", time.diff(t3,t4))
    // Returned 54832778815 in 8.78 ms, answer was correct.
}

// 4 loads of copypasta below, and no one cares.
pt1_test :: proc() -> int {
    MONKEYNUMBER :: 4

    // Test data.
    testm0 : [dynamic] int
    testm1 : [dynamic] int
    testm2 : [dynamic] int
    testm3 : [dynamic] int
    
    append(&testm0, 79, 98)
    testm0f :: proc(x : int) -> int { return x * 19 }
    testm0t  :: [3] int {23,2,3}

    append(&testm1, 54, 65, 75, 74)
    testm1f :: proc(x : int) -> int { return x + 6 }
    testm1t :: [3] int {19,2,0}

    append(&testm2, 79, 60, 97)
    testm2f :: proc(x : int) -> int { return x * x}
    testm2t :: [3] int {13,1,3}

    append(&testm3, 74)
    testm3f :: proc(x : int) -> int { return x + 3 }
    testm3t :: [3] int {17,0,1}

    testm_list : [MONKEYNUMBER] ^[dynamic] int
    testm_list = {&testm0, &testm1, &testm2, &testm3}
    testm_fns  : [MONKEYNUMBER] proc(int) -> int
    testm_fns  = { testm0f, testm1f, testm2f, testm3f }
    testm_ts   : [MONKEYNUMBER] [3] int
    testm_ts   = {testm0t, testm1t, testm2t, testm3t}
    testm_inspections : [MONKEYNUMBER] int = 0
    
    MODULUS      :: 13 * 17 * 19 * 23

    // Begin loop.
    ITERATIONS :: 20
    for iter in 1..=ITERATIONS {
	for mn in 0..=MONKEYNUMBER-1 {
	    fn    := testm_fns[mn]
	    tinfo := testm_ts[mn]
	    for luggage in testm_list[mn] {
		testm_inspections[mn] += 1
		inspected := fn(luggage)
		inspected /= 3
		if inspected >= MODULUS {
		    inspected %= MODULUS
		}
		test_luggage := (inspected % tinfo[0]) == 0
		if test_luggage {
		    append(testm_list[tinfo[1]], inspected)
		} else {
		    append(testm_list[tinfo[2]], inspected)
		}
	    }
	    clear(testm_list[mn])
	}
	f.println(testm_inspections)
    }
    f.println("Luggage after its:", testm0,testm1,testm2,testm3)
    f.println("Number of inspections:", testm_inspections)
    // Calculate product of largest 2.
    largest1 := 0
    largest2 := 0
    for number, i in testm_inspections {
	switch {
	case number > largest1:
	    largest2 = largest1
	    largest1 = number
	case largest1 >= number && number > largest2:
	    largest2 = number
	}
    }
    f.println("Largest two values:", largest1, largest2)
    return largest1 * largest2
}


pt1 :: proc() -> int {
    MONKEYNUMBER :: 8

    // Test data.
    m0 : [dynamic] int
    m1 : [dynamic] int
    m2 : [dynamic] int
    m3 : [dynamic] int
    m4 : [dynamic] int
    m5 : [dynamic] int
    m6 : [dynamic] int
    m7 : [dynamic] int
    
    append(&m0, 76, 88, 96, 97, 58, 61, 67)
    m0f :: proc(x : int) -> int { return x * 19 }
    m0t :: [3] int { 3, 2, 3}

    append(&m1, 93, 71, 79, 83, 69, 70, 94, 98)
    m1f :: proc(x : int) -> int { return x + 8 }
    m1t :: [3] int { 11,5,6}
    
    append(&m2,50, 74, 67, 92, 61, 76)
    m2f :: proc(x : int) -> int { return x * 13 }
    m2t :: [3] int { 19,3,1}
    
    append(&m3, 76, 92)
    m3f :: proc(x : int) -> int { return x + 6 }
    m3t :: [3] int { 5,1,6}

    append(&m4, 74, 94, 55, 87, 62)
    m4f :: proc(x : int) -> int { return x + 5 }
    m4t :: [3] int { 2,2,0 }

    append(&m5, 59, 62, 53, 62)
    m5f :: proc(x : int) -> int { return x * x }
    m5t :: [3] int { 7,4,7}
    
    append(&m6, 62)
    m6f :: proc(x : int) -> int { return x + 2 }
    m6t :: [3] int { 17, 5 ,7 }

    append(&m7, 85, 54, 53)
    m7f :: proc(x : int) -> int { return x + 3 }
    m7t :: [3] int {13,4,0}

    m_list : [MONKEYNUMBER] ^[dynamic] int
    m_list = {&m0, &m1, &m2, &m3, &m4, &m5, &m6, &m7}
    m_fns  : [MONKEYNUMBER] proc(int) -> int
    m_fns  = { m0f, m1f, m2f, m3f, m4f, m5f, m6f, m7f}
    m_ts   : [MONKEYNUMBER] [3] int
    m_ts   = {m0t, m1t, m2t, m3t, m4t, m5t, m6t, m7t}
    m_inspections : [MONKEYNUMBER] int = 0
    
    MODULUS      :: 2 * 3 * 5 * 7 * 11 * 13 * 17 * 19

    // Begin loop.
    ITERATIONS :: 20
    for iter in 1..=ITERATIONS {
	for mn in 0..=MONKEYNUMBER-1 {
	    fn    :=  m_fns[mn]
	    tinfo :=  m_ts[mn]
	    for luggage in  m_list[mn] {
		m_inspections[mn] += 1
		inspected := fn(luggage)
		inspected /= 3
		if inspected >= MODULUS {
		    inspected %= MODULUS
		}
		test_luggage := (inspected % tinfo[0]) == 0
		if test_luggage {
		    append(m_list[tinfo[1]], inspected)
		} else {
		    append(m_list[tinfo[2]], inspected)
		}
	    }
	    clear(m_list[mn])
	}
    }
    f.println("Luggage after its:")
    for mp in m_list { f.println(mp) }
    f.println("Number of inspections:", m_inspections)
    // Calculate product of largest 2.
    largest1 := 0
    largest2 := 0
    for number, i in m_inspections {
	switch {
	case number > largest1:
	    largest2 = largest1
	    largest1 = number
	case largest1 >= number && number > largest2:
	    largest2 = number
	}
    }
    f.println("Largest two values:", largest1, largest2)
    return largest1 * largest2
}


pt2_test :: proc() -> int {
    MONKEYNUMBER :: 4

    // Test data.
    testm0 : [dynamic] int
    testm1 : [dynamic] int
    testm2 : [dynamic] int
    testm3 : [dynamic] int
    
    append(&testm0, 79, 98)
    testm0f :: proc(x : int) -> int { return x * 19 }
    testm0t  :: [3] int {23,2,3}

    append(&testm1, 54, 65, 75, 74)
    testm1f :: proc(x : int) -> int { return x + 6 }
    testm1t :: [3] int {19,2,0}

    append(&testm2, 79, 60, 97)
    testm2f :: proc(x : int) -> int { return x * x}
    testm2t :: [3] int {13,1,3}

    append(&testm3, 74)
    testm3f :: proc(x : int) -> int { return x + 3 }
    testm3t :: [3] int {17,0,1}

    testm_list : [MONKEYNUMBER] ^[dynamic] int
    testm_list = {&testm0, &testm1, &testm2, &testm3}
    testm_fns  : [MONKEYNUMBER] proc(int) -> int
    testm_fns  = { testm0f, testm1f, testm2f, testm3f }
    testm_ts   : [MONKEYNUMBER] [3] int
    testm_ts   = {testm0t, testm1t, testm2t, testm3t}
    testm_inspections : [MONKEYNUMBER] int = 0
    
    MODULUS      :: 13 * 17 * 19 * 23

    // Begin loop.
    ITERATIONS :: 10_000
    for iter in 1..=ITERATIONS {
	for mn in 0..=MONKEYNUMBER-1 {
	    fn    := testm_fns[mn]
	    tinfo := testm_ts[mn]
	    for luggage in testm_list[mn] {
		testm_inspections[mn] += 1
		inspected := fn(luggage)
		//		inspected /= 3
		if inspected >= MODULUS {
		    inspected %= MODULUS
		}
		test_luggage := (inspected % tinfo[0]) == 0
		if test_luggage {
		    append(testm_list[tinfo[1]], inspected)
		} else {
		    append(testm_list[tinfo[2]], inspected)
		}
	    }
	    clear(testm_list[mn])
	}
    }
    f.println("Luggage after its:", testm0,testm1,testm2,testm3)
    f.println("Number of inspections after", ITERATIONS, "rounds:", testm_inspections)
    // Calculate product of largest 2.
    largest1 := 0
    largest2 := 0
    for number, i in testm_inspections {
	switch {
	case number > largest1:
	    largest2 = largest1
	    largest1 = number
	case largest1 >= number && number > largest2:
	    largest2 = number
	}
    }
    f.println("Largest two values:", largest1, largest2) 
   return largest1 * largest2
}



pt2 :: proc() -> int {
    MONKEYNUMBER :: 8

    // Test data.
    m0 : [dynamic] int
    m1 : [dynamic] int
    m2 : [dynamic] int
    m3 : [dynamic] int
    m4 : [dynamic] int
    m5 : [dynamic] int
    m6 : [dynamic] int
    m7 : [dynamic] int
    
    append(&m0, 76, 88, 96, 97, 58, 61, 67)
    m0f :: proc(x : int) -> int { return x * 19 }
    m0t :: [3] int { 3, 2, 3}

    append(&m1, 93, 71, 79, 83, 69, 70, 94, 98)
    m1f :: proc(x : int) -> int { return x + 8 }
    m1t :: [3] int { 11,5,6}
    
    append(&m2,50, 74, 67, 92, 61, 76)
    m2f :: proc(x : int) -> int { return x * 13 }
    m2t :: [3] int { 19,3,1}
    
    append(&m3, 76, 92)
    m3f :: proc(x : int) -> int { return x + 6 }
    m3t :: [3] int { 5,1,6}

    append(&m4, 74, 94, 55, 87, 62)
    m4f :: proc(x : int) -> int { return x + 5 }
    m4t :: [3] int { 2,2,0 }

    append(&m5, 59, 62, 53, 62)
    m5f :: proc(x : int) -> int { return x * x }
    m5t :: [3] int { 7,4,7}
    
    append(&m6, 62)
    m6f :: proc(x : int) -> int { return x + 2 }
    m6t :: [3] int { 17, 5 ,7 }

    append(&m7, 85, 54, 53)
    m7f :: proc(x : int) -> int { return x + 3 }
    m7t :: [3] int {13,4,0}

    m_list : [MONKEYNUMBER] ^[dynamic] int
    m_list = {&m0, &m1, &m2, &m3, &m4, &m5, &m6, &m7}
    m_fns  : [MONKEYNUMBER] proc(int) -> int
    m_fns  = { m0f, m1f, m2f, m3f, m4f, m5f, m6f, m7f}
    m_ts   : [MONKEYNUMBER] [3] int
    m_ts   = {m0t, m1t, m2t, m3t, m4t, m5t, m6t, m7t}
    m_inspections : [MONKEYNUMBER] int = 0
    
    MODULUS      :: 2 * 3 * 5 * 7 * 11 * 13 * 17 * 19

    // Begin loop.
    ITERATIONS :: 10_000
    for iter in 1..=ITERATIONS {
	for mn in 0..=MONKEYNUMBER-1 {
	    fn    :=  m_fns[mn]
	    tinfo :=  m_ts[mn]
	    for luggage in  m_list[mn] {
		m_inspections[mn] += 1
		inspected := fn(luggage)
//		inspected /= 3
		if inspected >= MODULUS {
		    inspected %= MODULUS
		}
		test_luggage := (inspected % tinfo[0]) == 0
		if test_luggage {
		    append(m_list[tinfo[1]], inspected)
		} else {
		    append(m_list[tinfo[2]], inspected)
		}
	    }
	    clear(m_list[mn])
	}
    }
    f.println("Luggage after its:")
    for mp in m_list { f.println(mp) }
    f.println("Number of inspections:", m_inspections)
    // Calculate product of largest 2.
    largest1 := 0
    largest2 := 0
    for number, i in m_inspections {
	switch {
	case number > largest1:
	    largest2 = largest1
	    largest1 = number
	case largest1 >= number && number > largest2:
	    largest2 = number
	}
    }
    f.println("Largest two values:", largest1, largest2)
    return largest1 * largest2
}
