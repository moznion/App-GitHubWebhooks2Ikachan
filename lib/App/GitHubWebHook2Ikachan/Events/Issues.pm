package App::GitHubWebHook2Ikachan::Events::Issues;
use strict;
use warnings;
use utf8;

sub call {
    my ($class, $context) = @_;

    my $issue   = $context->dat->{issue};
    my $channel = $context->channel;

    my $msg  = $issue->{body};
    my $name = $issue->{user}->{login};
    my $url  = $issue->{html_url};

    my $subscribe_actions = $context->req->param('issues');

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

