val tree = LEAF;

(* test insert function *)
val tree1 = insert (tree, "t", 1);
val tree2 = insert (tree1, "s", 2);
val tree3 = insert (tree2, "p", 3);
val tree4 = insert (tree3, "i", 4);
val tree5 = insert (tree4, "p", 5);
val tree6 = insert (tree5, "f", 6);
val tree7 = insert (tree6, "b", 7);
val tree8 = insert (tree7, "s", 8);
val tree9 = insert (tree8, "t", 9);

(* test member function *)
member (tree9, "a");
member (tree9, "b");
member (tree9, "s");

(* test lookup function *)
lookup (tree8, "t");
lookup (tree9, "t");
lookup (tree3, "p");
lookup (tree5, "p");