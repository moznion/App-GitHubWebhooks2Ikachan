package App::GitHubWebHook2Ikachan;
use 5.008005;
use strict;
use warnings;
use JSON;
use Log::Minimal;
use Plack::Builder;
use Plack::Request;
use String::IRC;
use App::GitHubWebHook2Ikachan::Events;

our $VERSION = "0.01";

sub to_app {
    builder {
        enable 'AccessLog';

        sub {
            my $env = shift;
            my $req = Plack::Request->new($env);

            my $channel = $req->path_info;
            $channel =~ s!\A/+!!;
            unless ($channel) {
                die "Missing channel name";
            }
            infof("Post to %s", $channel);

            my $payload = $req->param('payload');
            unless ($payload) {
                die "Payload is nothing";
            }
            my $dat = decode_json($payload);
            infof("Payload: %s", $payload);

            my $event_name = $req->header('X-GitHub-Event');

            my $event_dispatcher = App::GitHubWebHook2Ikachan::Events->new(
                dat     => $dat,
                req     => $req,
                channel => $channel,
            );

            my $send_contents = $event_dispatcher->dispatch($event_name);
            if ($send_contents && ref $send_contents eq 'ARRAY') {
                if (ref $send_contents->[0] ne 'ARRAY') {
                    $send_contents = [$send_contents];
                }
                for my $send_content (@$send_contents) {
                    send_to_ikachan(@$send_content);
                }
            }

            return [200, ['Content-Type' => 'text/plain', 'Content-Length' => 2], ['OK']];
        };
    };
}

sub send_to_ikachan {
    my ($channel, $msg, $name, $url, $branch) = @_;

    $msg =~ s/\r?\n.*//g;

    my $green_message = "${msg} (\@${name})";
    if ($branch) {
        $green_message = "[$branch] $green_message";
    }

    my $text = String::IRC->new($green_message)->green . " ${url}";
    # my $res = $ua->post($IKACHAN_URL, [
    #     message => $text,
    #     channel => $channel,
    # ]);

    # TODO encode
    infof("POST %s, %s, %s, %s, %s", $channel, $msg, $name, $url, $branch || '-');
}

sub run {
    my $class = shift;

    my %args = @_ == 1 ? %{$_[0]} : @_;
    # if (!$args{listen} && !$args{port} && !$ENV{SERVER_STARTER_PORT}) {
    #     $args{port} = 4907;
    # }
    require Plack::Loader;
    Plack::Loader->auto(%args)->run($class->to_app);
}

1;
__END__

=encoding utf-8

=head1 NAME

App::GitHubWebHook2Ikachan - It's new $module

=head1 SYNOPSIS

    use App::GitHubWebHook2Ikachan;

=head1 DESCRIPTION

App::GitHubWebHook2Ikachan is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut

