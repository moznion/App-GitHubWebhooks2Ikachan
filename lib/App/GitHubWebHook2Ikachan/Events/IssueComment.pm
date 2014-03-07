package App::GitHubWebHook2Ikachan::Events::IssueComment;
use strict;
use warnings;
use utf8;

sub call {
    my ($class, $context) = @_;

    my $comment = $context->dat->{comment};

    my $msg  = $comment->{body};
    my $name = $comment->{user}->{login};
    my $url  = $comment->{html_url};

    return [$context->channel, $msg, $name, $url, ''];
}

1;

