package App::GitHubWebHook2Ikachan::Events::Push;
use strict;
use warnings;
use utf8;
use String::IRC;

sub call {
    my ($class, $context) = @_;

    my $dat    = $context->dat;
    my $branch = __PACKAGE__->_extract_branch_name($dat);

    # for merge commit (squash it)
    my $merge_commit;
    my $head_commit = $dat->{head_commit};
    if ($head_commit) {
        my $head_commit_msg = $head_commit->{message};
        if ($head_commit_msg && $head_commit_msg =~ /\AMerge/) { # XXX
            $merge_commit = [$head_commit];
        }
    }

    my $texts = [];
    for my $commit (@{$merge_commit || $dat->{commits} || []}) {
        my $user_name =    $commit->{author}->{username}
                        || $commit->{author}->{name}
                        || $commit->{committer}->{username}
                        || $commit->{committer}->{name};
        (my $commit_message = $commit->{message}) =~ s/\r?\n.*//g;
        my $url = $commit->{url};

        my $main_text = "[push to $branch] $commit_message ($user_name)";
        my $appendix  = $url;

        push @$texts, String::IRC->new($main_text)->green . " $appendix";
    }

    return $texts;
}

sub _extract_branch_name {
    my ($class, $dat) = @_;

    # e.g.
    #   ref: "refs/heads/__BRANCH_NAME__"
    my $branch;
    if (my $ref = $dat->{ref}) {
        $branch = (split qr!/!, $ref)[-1];
    }

    return $branch ? $branch : '';
}

1;

