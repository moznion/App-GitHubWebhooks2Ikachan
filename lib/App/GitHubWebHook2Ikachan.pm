package App::GitHubWebHook2Ikachan;
use 5.008005;
use strict;
use warnings;
use Encode qw/encode_utf8/;
use Getopt::Long;
use JSON;
use Log::Minimal;
use LWP::UserAgent;
use Plack::Builder;
use Plack::Runner;
use Plack::Request;
use String::IRC;
use Pod::Usage;
use App::GitHubWebHook2Ikachan::Events;
use Class::Accessor::Lite(
    new => '0',
    rw  => [qw/ua ikachan_url/],
);

our $VERSION = "0.01";

sub new {
    my ($class, $args) = @_;

    my $ua = LWP::UserAgent->new(
        agent => "App::GitHubWebHook2Ikachan (Perl)",
    );

    bless {
        ua          => $ua,
        ikachan_url => $args->{ikachan_url},
    }, $class;
}

sub to_app {
    my ($self) = @_;

    infof("ikachan url: %s", $self->ikachan_url);

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
            );

            my $send_texts = $event_dispatcher->dispatch($event_name);
            if ($send_texts)
                if (ref $send_texts ne 'ARRAY') {
                    $send_texts = [$send_texts];
                }
                for my $send_text (@$send_texts) {
                    $self->send_to_ikachan($channel, $send_text);
                }
            }

            return [200, ['Content-Type' => 'text/plain', 'Content-Length' => 2], ['OK']];
        };
    };
}

sub send_to_ikachan {
    my ($self, $channel, $text) = @_;

    my $res = $ua->post($self->ikachan_url, [
        message => $text,
        channel => $channel,
    ]);

    $text = encode_utf8($text);
    infof("POST %s", $text);
}

sub parse_options {
    my ($class, @argv) = @_;

    my $p = Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help pass_through)],
    );

    $p->getoptionsfromarray(\@argv, \my %opt, qw/
        ikachan_url=s
    /) or pod2usage();
    $opt{ikachan_url} || pod2usage();

    return (\%opt, \@argv);
}

sub run {
    my ($self, @argv) = @_;

    my $runner = Plack::Runner->new;
    $runner->parse_options('--port=5555', @argv);
    $runner->run($self->to_app);
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

