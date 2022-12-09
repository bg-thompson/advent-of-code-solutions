package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"
import   "core:time"

when ODIN_DEBUG {
    FILENAME :: `test.txt`
} else {
    FILENAME :: `data.txt`
}

FILE :: string(#load(FILENAME))

when ODIN_DEBUG {
    DIMS :: [2] int {5,5}
} else {
    DIMS :: [2] int {99,99}
}

GridTree : [DIMS.y][DIMS.x] i8
GridVis  : [DIMS.y][DIMS.x] i8

main :: proc() {
    // Load data into grid.
    lines := s.split_lines(FILE)
    assert(len(lines[0]) == int(DIMS.x))
    for l, i in lines {
	if l == "" { continue }
	for n, j in l {
	    num := i8(n - '0')
	    GridTree[i][j] = i8(num)
	}
    }
    when ODIN_DEBUG { for l in GridTree { f.println(l) } }
    f.println("")
    when ODIN_DEBUG { for l in rotate_grid_pi_2(GridTree) { f.println(l) } }
    f.println("")
    s1 := time.now()
    sol1 := pt1()
    e1 := time.now()
    f.println("Pt1 Solution:", sol1)
    f.println("Pt1 Time:", time.diff(s1, e1))
    // Returned 1789, answer was correct.
    s2   := time.now()
    sol2 := pt2()
    e2   := time.now()
    f.println("Pt2 Solution:", sol2)
    f.println("Pt2 Time:", time.diff(s2, e2))
    // Returned 314820, answer was correct.
}

rotate_grid_pi_2 :: proc (orig : [$N] [$M] $T ) -> ( rot : [M] [N] T) {
    for y in 0..=M-1 {
	for x in 0..=N-1 { rot[M-1-x][y]  = orig[y][x] }
    }
    return
}

pt1 :: proc() -> int {
    // Copied from main for use in timing test.
    lines := s.split_lines(FILE)
    assert(len(lines[0]) == int(DIMS.x))
    for l, i in lines {
	if l == "" { continue }
	for n, j in l {
	    num := i8(n - '0')
	    GridTree[i][j] = i8(num)
	}
    }
    
    grid := GridTree
    vis := visible_from_left(grid, GridVis)
    when ODIN_DEBUG {
	f.println("Vis1:")
	for l in vis { f.println(l) }
	f.println("")
    }

    for i in 1..=3 {
	grid = rotate_grid_pi_2(grid)
	vis  = rotate_grid_pi_2(vis)
	vis  = visible_from_left(grid, vis)
    }

    when ODIN_DEBUG {
	rot := rotate_grid_pi_2(vis)
	for l in rot { f.println(l) }
	f.println("")
    }
    // Count number of visible trees
    visible_trees := 0
    for l in vis {
	for v in l { visible_trees += int(v) }
    }
    return visible_trees
}

visible_from_left :: proc( grid : [$N][$M] i8, old_vis : [N][M] i8 ) -> ( new_vis : [N][M] i8 ) {
    // Copy data.
    new_vis = old_vis
    // Going T to B, determine if a tree is visible from left.
    // Stop if tree has height 9. //@optimization 9 can be generalized.
    l1: for y in 0..=N-1 {
	cmh := i8(-1)
	l2: for x in 0..=M-1 {
	    treeh := grid[y][x]
	    if treeh > cmh {
		new_vis[y][x] = 1
		cmh = treeh
		if treeh == 9 {
		    continue l1
		}
	    }
	}
    }
    return
}

pt2 :: proc() -> int {
    GridVd : [DIMS.y][DIMS.x] int
    GridVd = 1
    grid := GridTree
    vd   := GridVd
    
    vd = viewing_distance_left(grid, vd)
    when ODIN_DEBUG {
	f.println("Vd1:")
	for l in vd { f.println(l) }
	f.println("")
    }

    for i in 1..=3 {
	grid = rotate_grid_pi_2(grid)
	vd   = rotate_grid_pi_2(vd)
	vd   = viewing_distance_left(grid, vd)
    }
    
    when ODIN_DEBUG {
	f.println("Scenic score:")
	rot := rotate_grid_pi_2(vd)
	for l in rot { f.println(l) }
	f.println("")
    }
    // Calculate max
    max_scenic := 0
    for l in vd {
	for sc in l {
	    max_scenic = max(max_scenic, sc)
	}
    }
    return max_scenic
}

viewing_distance_left :: proc( grid : [$N][$M] i8, vd_old : [N][M] int) -> ( vd_new : [N][M] int ) {
//    vd_new = vd_old
    // Going L to R, T to B, determine the vd from a tree looking left.
    l1: for y in 0..=N-1 {
	// Initialize blocker-index row.
	blocker_indexes : [10] int
	blocker_indexes = 0
	// blocker_indexes[i] contains the nearest x-index of a tree
	// which will block a tree of height i.
	for x in 0..=M-1 {
	    tree_height   := int(grid[y][x])
	    blocker_index := blocker_indexes[tree_height]
	    vd_new[y][x] = (x - blocker_index) * vd_old[y][x]
	    // Update blocker indexes.
	    for b in 0..=tree_height {
		blocker_indexes[b] = x
	    }
	}
    }
    return
}
