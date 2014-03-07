# NAME

App::GitHubWebHook2Ikachan - Server to notify GitHub Webhook to [App::Ikachan](https://metacpan.org/pod/App::Ikachan)

# SYNOPSIS

    $ githubwebhook2ikachan --ikachan_url=http://your-ikachan-server.com --port=12345

# DESCRIPTION

App::GitHubWebHook2Ikachan is the server to notify GitHub Webhook to [App::Ikachan](https://metacpan.org/pod/App::Ikachan).

Now, this application supports `issues`, `pull_request`, `issue_comment`, and `push` webhooks of GitHub.

# USAGE

Please set up webhooks at GitHub (if you want to know details, please refer [http://developer.github.com/v3/activity/events/types/](http://developer.github.com/v3/activity/events/types/)).

Payload URL will be like so;

    http://your-githubwebhook2ikachan-server.com/${path}?subscribe=issues,pull_request&issues=opened,closed&pull_request=opened

This section describes the details.

- PATH INFO
    - ${path}

        Destination of IRC channel to send message. This is essential.
- QUERY PARAMETERS
    - subscribe

        Event names to subscribe. Specify by comma separated value.
        Now, this application supports `issues`, `pull_request`, `issue_comment`, and `push`.

        If you omit this parameter, it will subscribe the all of supported events.

    - issues

        Action names to subscribe for `issues` event. Specify by comma separated value.
        Now this application supports `opened`, `closed`, and `reopend`.

        If you omit this parameter, it will subscribe the all of supported actions of `issues`.

    - pull\_request

        Action names to subscribe for `pull_request` event. Specify by comma separated value.
        Now this application supports `opened`, `closed`, `reopend`, and `synchronized`.

        If you omit this parameter, it will subscribe the all of supported actions of `pull_request`.

# SEE ALSO

[http://developer.github.com/v3/activity/events/types/](http://developer.github.com/v3/activity/events/types/).

# LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

moznion <moznion@gmail.com>
