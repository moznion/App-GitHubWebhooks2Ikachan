package App::GitHubWebHook2Ikachan::Events::PullRequest;
use strict;
use warnings;
use utf8;

sub call {
    my ($class, $context) = @_;

    my $pull_request = $context->dat->{pull_request};
    my $channel      = $context->channel;

    my $msg  = $pull_request->{body};
    my $name = $pull_request->{user}->{login};
    my $url  = $pull_request->{html_url};

    my $subscribe_actions = $context->req->param('pull_request');

    # Allow all actions
    if (!$subscribe_actions) {
        return [$channel, $msg, $name, $url, ''];
    }

    # Filter by specified actions
    my $action = $context->dat->{action};
    if (grep { $_ eq $action } split(/,/, $subscribe_actions)) {
        return [$channel, $msg, $name, $url, ''];
    }

    return; # Not match any actions
}

1;

