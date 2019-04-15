<?php
namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use OpenCensus\Trace\Exporter\JaegerExporter;
use OpenCensus\Trace\Tracer;
use OpenCensus\Trace\Integrations\Laravel;
use OpenCensus\Trace\Integrations\Mysql;
use OpenCensus\Trace\Integrations\PDO;
use OpenCensus\Trace\Exporter\EchoExporter;
use OpenCensus\Trace\Exporter\FileExporter;

class OpenCensusProvider extends ServiceProvider
{
    public function boot()
    {
        if (php_sapi_name() == 'cli') {
            return;
        }

        // Enable OpenCensus extension integrations
        Laravel::load();
        Mysql::load();
        PDO::load();

        $options = [
            "host" => "jaeger",
            "port" => "6831",
            "tags" => [],
            'client' => null
        ];

        // Start the request tracing for this request
        $exporter = new JaegerExporter( 'varun-laravel' ,$options);
        // $exporter = new EchoExporter();
        // $exporter = new FileExporter('/var/www/laravel/.docker/logs/opentrace.log');
        Tracer::start($exporter);

        // Create a span that starts from when Laravel first boots (public/index.php)
        Tracer::inSpan(['name' => 'bootstrap', 'startTime' => LARAVEL_START], function () {});
    }
}