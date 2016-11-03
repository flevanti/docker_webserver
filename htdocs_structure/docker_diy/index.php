<?php
session_start();
$hostname = $_ENV['HOSTNAME'];


?>

<style>
    body { background: #343536;
        color: #63de00;
        font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
        line-height: 1.5em;
    }
</style>

<body class="body">
<h1>WEBSERVER CONTAINER<br>CONFIGURATION TOOL</h1>
hostname <?php echo $hostname;?><br>

<h3>XDEBUG:</h3>
<form action="/" method="post">
    <p>
    Update remote autostart flag to
    <input type="text" name="xdebugremoteautostart_value" value="" size="2">
    <input type="submit" value="save" name="xdebugremoteautostart">
    (accepted values are 0 or 1)
    </p>
    <p>
        Update remote enable flag to
        <input type="text" name="xdebugremoteenable_value" value="" size="2">
        <input type="submit" value="save" name="xdebugremoteenable">
        (accepted values are 0 or 1)
    </p>
    <p>
        Update remote connect back flag to
        <input type="text" name="xdebugremoteconnectback_value" value="" size="2">
        <input type="submit" value="save" name="xdebugremoteconnectback">
        (accepted values are 0 or 1)
    </p>
    <p>
        Update remote port
        <input type="text" name="xdebugremoteport_value" value="" size="2">
        <input type="submit" value="save" name="xdebugremoteport">
        (1025 -> 66635)
    </p>
    <p>
        Update remote port
        <input type="text" name="xdebugremotehost_value" value="" size="2">
        <input type="submit" value="save" name="xdebugremotehost">
        (Can be an host or IP address)
    </p>
    <p>
        Update idekey
        <input type="text" name="xdebugidekey_value" value="" size="2">
        <input type="submit" value="save" name="xdebugidekey">
    </p>
</form>





</body>



