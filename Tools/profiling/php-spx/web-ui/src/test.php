<?php

// your application code

/*echo "--test---";
for ($i = 0; $i <= 1000; $i++) {
    $a = $i * $i;
}*/

function slowFunction()
{
    usleep(200000);
}

for ($i = 0; $i < 5; $i++) {
    slowFunction();
}

echo "Hello SPX!";
