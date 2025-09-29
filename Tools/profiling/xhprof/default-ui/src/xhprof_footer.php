<?php 


$data = xhprof_disable();
file_put_contents(
      "/profiles/" . uniqid() . ".malidkha.xhprof",
     serialize($data)
);

