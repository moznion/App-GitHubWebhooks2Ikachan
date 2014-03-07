package App::GitHubWebHook2Ikachan;
use 5.008005;
use strict;
use warnings;
use JSON;
use Log::Minimal;
use Plack::Builder;
use Plack::Request;
use String::IRC;

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
                die "Missing channerl name"; # TODO
            }
            infof("Post to %s", $channel);

            my $payload = $req->param('payload');
            unless ($payload) {
                die "Payload is nothing"; # TODO
            }
            my $dat = decode_json($payload);
            infof("Payload: %s", $payload);

            my $event = $req->header('X-GitHub-Event');

            if ($event eq 'issues') {
                my $issue = $dat->{issue};

                my $msg  = $issue->{body};
                my $name = $issue->{user}->{login};
                my $url  = $issue->{html_url};

                # TODO switch by action
                # $action = $dat->{action};

                send_to_ikachan($channel, $msg, $name, $url, '');
            }
            elsif ($event eq 'pull_request') {
                my $pull_request = $dat->{pull_request};

                my $msg  = $pull_request->{body};
                my $name = $pull_request->{user}->{login};
                my $url  = $pull_request->{html_url};

                # TODO switch by action
                # $action = $dat->{action};

                send_to_ikachan($channel, $msg, $name, $url, '');
            }
            elsif ($event eq 'issue_comment') {
                my $comment = $dat->{issue_comment};

                my $msg  = $comment->{body};
                my $name = $comment->{user}->{login};
                my $url  = $comment->{html_url};

                send_to_ikachan($channel, $msg, $name, $url, '');
            }
            elsif ($event eq 'push') {
                my $branch = _extract_branch_name($dat);

                # for merge commit (squash it)
                my $merge_commit;
                my $head_commit = $dat->{head_commit};
                if ($head_commit) {
                    my $head_commit_msg = $head_commit->{message};
                    if ($head_commit_msg && $head_commit_msg =~ /\AMerge/) { # XXX
                        $merge_commit = [$head_commit];
                    }
                }

                for my $commit (@{$merge_commit || $dat->{commits} || []}) {
                    my $name = $commit->{author}->{username}
                        || $commit->{author}->{name}
                        || $commit->{committer}->{username}
                        || $commit->{committer}->{name};
                    my $msg = $commit->{message};
                    my $url = $commit->{url};

                    send_to_ikachan($channel, $msg, $name, $url, $branch);
                }
            }

            return [200, ['Content-Type' => 'text/plain', 'Content-Length' => 2], ['OK']];
        };
    };
}

sub _extract_branch_name {
    my ($dat) = @_;

    # e.g.
    #   ref: "refs/heads/__BRANCH_NAME__"
    my $branch;
    if (my $ref = $dat->{ref}) {
        $branch = (split qr!/!, $ref)[-1];
    }

    return $branch ? $branch : '';
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

