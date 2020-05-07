val tree = LEAF

(* test insert function *)
val tree1 = insert (tree, "a", 1);
val tree2 = insert (tree1, "b", 2);
val tree3 = insert (tree2, "c", 3);
val tree4 = insert (tree3, "d", 4);
val tree5 = insert (tree4, "e", 5);
val tree6 = insert (tree5, "f", 6);
val tree7 = insert (tree6, "g", 7);
val tree8 = insert (tree7, "h", 8);
val tree9 = insert (tree8, "i", 9);

(* test member function *)
member (tree9, "a");
member (tree9, "b");
member (tree9, "s");

(* test lookup function *)
lookup (tree8, "h");
lookup (tree9, "i");
lookup (tree3, "a");
lookup (tree5, "b");