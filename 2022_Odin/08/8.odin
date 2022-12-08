package aoc22

import f "core:fmt"
import s "core:strings"
import v "core:strconv"

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

GridTree : [DIMS.y][DIMS.x] u8
GridVis  : [DIMS.y][DIMS.x] u8

main :: proc() {
    // Load data into grid.
    lines := s.split_lines(FILE)
    assert(len(lines[0]) == int(DIMS.x))
    for l, i in lines {
	if l == "" { continue }
	for n, j in l {
	    num := u8(n - '0')
	    GridTree[i][j] = u8(num)
	}
    }
    when ODIN_DEBUG { for l in GridTree { f.println(l) } }
    f.println("")
    when ODIN_DEBUG { for l in rotate_grid_pi_2(GridTree) { f.println(l) } }
    f.println("")
    sol1 := pt1()
    f.println("Pt1 Solution:", sol1)
    // Returned 1789, answer was correct.
    sol2 := pt2()
    f.println("Pt2 Solution:", sol2)
    // Returned 314820, answer was correct.
}

rotate_grid_pi_2 :: proc (orig : [$N] [$M] $T ) -> ( rot : [M] [N] T) {
    for y in 0..=M-1 {
	for x in 0..=N-1 { rot[M-1-x][y]  = orig[y][x] }
    }
    return
}

pt1 :: proc() -> int {
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

// Not optimized, but since Odin is compiled we'll be fine.
visible_from_left :: proc( grid : [$N][$M] u8, old_vis : [N][M] u8 ) -> ( new_vis : [N][M] u8 ) {
    // Copy data.
    new_vis = old_vis
    // Going L to R, T to B, determine if a tree is visible from above.
    l1: for y in 0..=N-1 {
	l2: for x in 0..=M-1 {
	    tree := grid[y][x]
	    l3: for o in 0..=x {
		if o == x { continue }
		if grid[y][o] >= tree { continue l2 }
	    }
	    // If ip reaches here, tree visible.
	    new_vis[y][x] = 1
	}
    }
    return
}

pt2 :: proc() -> int {
    GridVd : [DIMS.y][DIMS.x] int
    for i in 0..=DIMS.y-1 {
	for j in 0..=DIMS.x-1 { GridVd = 1 }
    }
    grid := GridTree
    vd   := GridVd
    
    vd = viewing_distance_left(grid, vd)
    when ODIN_DEBUG {
	f.println("Vd1:")
	for l in GridVd { f.println(l) }
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

viewing_distance_left :: proc( grid : [$N][$M] u8, vd_old : [N][M] int) -> ( vd_new : [N][M] int ) {
    vd_new = vd_old
    // Going L to R, T to B, determine the vd from a tree looking left.
    l1: for y in 0..=N-1 {
	l2: for x in 0..=M-1 {
	    th := grid[y][x]
	    cvd := 0
	    l3: for o in 0..=x {
		if o == 0 { continue }
		cvd += 1
		if grid[y][x-o] >= th {
		    vd_new[y][x] *= cvd
		    continue l2
		}
	    }
	    vd_new[y][x] *= cvd
	}
    }
    return		
}
