package App::GitHubWebHook2Ikachan::Events::Issues;
use strict;
use warnings;
use utf8;
use String::IRC;

sub call {
    my ($class, $context) = @_;

    my $issue = $context->dat->{issue};

    my $issue_title = $issue->{title};
    my $user_name   = $issue->{user}->{login};
    my $url = $issue->{html_url};

    my $action = $context->dat->{action};
    my $subscribe_actions = $context->req->param('issues');
    if (
        !$subscribe_actions # Allow all actions
        || grep { $_ eq $action } split(/,/, $subscribe_actions) # Filter by specified actions
    ) {
        my $main_text = "[issue $action] $issue_title ($user_name)";
        my $appendix  = $url;

        return String::IRC->new($main_text)->green . " $appendix";
    }

    return; # Not match any actions
}

1;

