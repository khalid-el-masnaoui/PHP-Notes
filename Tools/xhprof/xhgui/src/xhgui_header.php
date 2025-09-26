<?php 

require '/var/www/xhgui/vendor/autoload.php';
$config = include '/var/www/xhgui/config/config.php';
$profiler = new \Xhgui\Profiler\Profiler($config);
$profiler->start();

