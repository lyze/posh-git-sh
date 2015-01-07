posh-git-bash
=============

Background
----------

This was my first venture into bash scripting, so I decided to make a port of
posh-git, which, in my humble opinion, is fantastic (and can be found at found
at https://github.com/dahlbyk/posh-git).

I wanted a simple solution to display the status of my git prompt in my shell.
Furthermore, I wanted it to be easy to set up, so that I wouldn't have to download
multiple files and organize them somewhere. As a result, here we are with this single
monolithic shell script to do it all.

I based my work off of
https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh

This is distributed under the GNU GPL v2.0. I hope that you may find some use of
it. Please do not hesitate to contact me about any issues or requests.


Installation Instructions
=========================
1. Copy this file to somewhere (e.g. `~/git-prompt.sh`).
2. Add the following line to your `.bashrc`:

        source ~/git-prompt.sh

3.  If you are using bash, you should call `__git_ps1` in your `PROMPT_COMMAND`
    variable. The function `__git_ps1` takes two parameters as in
    `__git_ps1 <string_to_prepend> <string_to_append>`. This function updates `PS1`
    accordingly. For example, the following

        PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ ";'$PROMPT_COMMAND

    will show username, at-sign, host, colon, cwd, then various status strings,
    followed by dollar and space, as your prompt. This invocation prepends this
    instruction to the existing value of `PROMPT_COMMAND`.


The Prompt
----------
By default, the status summary has the following format:

    [{HEAD-name} +A ~B -C !D | +E ~F -G !H]

* `{HEAD-name}` is the current branch, or the SHA of a detached HEAD
 * Cyan means the branch matches its remote
 * Green means the branch is ahead of its remote (green light to push)
 * Red means the branch is behind its remote
 * Yellow means the branch is both ahead of and behind its remote
* ABCD represent the index; EFGH represent the working directory
 * `+` = Added files
 * `~` = Modified files
 * `-` = Removed files
 * `!` = Conflicted files
 * As in `git status`, index status is dark green and working directory status
 is dark red

For example, a status of `[master +0 ~2 -1 | +1 ~1 -0]` corresponds to the
following `git status`:

    # On branch master
    #
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #        modified:   this-changed.txt
    #        modified:   this-too.txt
    #        deleted:    gone.ps1
    #
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #        modified:   not-staged.ps1
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #        new.file

![Example usage](http://i.imgur.com/vNShFtg.png)

To get the above prompt display, I have the following in my `.bashrc`:

        export PROMPT_COMMAND='__git_ps1 "\\[\[\e[0;32m\]\u@\h \[\e[0;33m\]\w" " \[\e[1;34m\]\n\$\[\e[0m\] ";'$PROMPT_COMMAND


Configuration Options
=====================

This script should work out of the box. Available options are set through
your git configuration files. This allows you to control the prompt display on a
per-repository basis. These files are most likely called `.gitconfig`; an 
example illustrating the syntax of these files can be found at
http://git-scm.com/docs/git-config#_example.
```
bash.describeStyle
bash.enableFileStatus
bash.enableGitStatus
bash.showStatusWhenZero
bash.showUpstream
```

bash.describeStyle
------------------

This option controls if you would like to see more information about the
identity of commits checked out as a detached `HEAD`. This is also controlled
by the legacy environment variable `GIT_PS1_DESCRIBESTYLE`.

Option   | Description
-------- | -----------
contains | relative to newer annotated tag `(v1.6.3.2~35)`
branch   | relative to newer tag or branch `(master~4)`
describe | relative to older annotated tag `(v1.6.3.1-13-gdd42c2f)`
default  | exactly matching tag

bash.enableFileStatus
---------------------

Option | Description
------ | -----------
true   | _Default_. The script will query for all file indicators every time.
false  | No file indicators will be displayed. The script will not query upstream for differences. Branch color-coding information is still displayed.

bash.enableGitStatus
--------------------

Option | Description
------ | -----------
true   | _Default_. Color coding and indicators will be shown.
false  | The script will not run.

bash.showStashState
-------------------

Option | Description
------ | -----------
true   | _Default_. An indicator will display if the stash is not empty.
false  | An indicator will not display the stash status.

bash.showStatusWhenZero
-----------------------

Option | Description
------ | -----------
true   | Indicators will be shown even if there are no updates to the index or working tree. 
false  | _Default_. No file change indicators will be shown if there are no changes to the index or working tree.

bash.showUpstream
-----------------

By default, `__git_ps1` will compare `HEAD` to your `SVN` upstream if it can
find one, or `@{upstream}` otherwise. This is also controlled by the legacy
environment variable `GIT_PS1_SHOWUPSTREAM`.

Option | Description
------ | -----------
legacy | Does not use the `--count` option available in recent versions of `git-rev-list`
git    | _Default_. Always compares `HEAD` to `@{upstream}`
svn    | Always compares `HEAD` to `SVN` upstream
