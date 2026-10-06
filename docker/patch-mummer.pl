#!/usr/bin/perl
# 仅修复非交互绘图的信号归属和权限预检，不改比对/绘图数据算法。
use strict;
use warnings;
use File::Copy qw(copy);
my $root = shift @ARGV or die "missing installed MUMmer prefix\n";
for my $spec (
    ["$root/bin/mummerplot", "mummerplot.original"],
    ["$root/lib/mummer/Foundation.pm", "Foundation.pm.original"]
) {
    my ($path, $name) = @$spec;
    copy($path, "$root/share/doc/mummer4/$name") or die "backup $path: $!";
    open my $in, '<', $path or die "$path: $!";
    local $/;
    my $text = <$in>;
    close $in;
    my $count;
    if ($name eq "mummerplot.original") {
        # 1 是上游未fork时的sentinel，绝不能向其发送信号。
        $count = ($text =~ s/kill 1, \$child;/kill 1, \$child if defined(\$child) \&\& \$child > 1;/g);
    } else {
        # ACL/virtiofs 的实际权限可能不同于 stat mode bits；真实 open 仍作最终权限判断。
        $count = ($text =~ s/   use strict;\n   use Cwd;/   use strict;\n   use filetest 'access';\n   use Cwd;/g);
    }
    die "unexpected upstream structure: $path ($count matches)\n" unless $count == 1;
    open my $out, '>', $path or die "$path: $!";
    print {$out} $text;
    close $out or die "$path: $!";
}
