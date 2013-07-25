{
    if ($2 > $4) {
        min = $4;
    } else {
        min = $2
    }
    printf("%0.16f %f\n", $1 * $3, min);
}
