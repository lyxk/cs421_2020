type key = string
datatype 'a tree = LEAF | TREE of 'a tree * key * 'a * 'a tree

exception KeyNotFound

fun insert (LEAF, x, value) = TREE (LEAF, x, value, LEAF)
    | insert (TREE (l, k, v, r), x, value) = 
        if x = k then TREE (l, x, value, r)
        else if x < k then TREE (insert (l, x, value), k, v, r) 
        else TREE (l, k, v, insert (r, x, value))

fun member (LEAF, x) = false
    | member (TREE (l, k, v, r), x) = 
        if x = k then true 
        else if x < k then member (l, x) 
        else member (r, x)

fun lookup (LEAF, x) = raise KeyNotFound
    | lookup (TREE (l, k, v, r), x) = 
        if x = k then v
        else if x < k then lookup (l, x)
        else lookup(r, x)