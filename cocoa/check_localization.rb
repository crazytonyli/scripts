#!/usr/bin/ruby

def usage
    print <<USAGE
Usage: #{$0} /path/to/Resource
USAGE
end

def l10n_keys(file)
    keys = Array.new()
    File.open(file).read().each_line do |line|
        #if line.strip.length > 0 and !line.lstrip.start_with?('/*') then
        if line.match(/^".*"\s+=\s+".*";\s+$/) then
            keys.push(line.split('=')[0].strip)
        end
    end
    return keys
end

def missing_keys(keys1, keys2)
    missing = Array.new
    keys1.each do |key|
        if !keys2.include?(key) then
            missing.push(key)
        end
    end
    return missing
end

def check_l10n(file1, file2)
    keys1 = l10n_keys(file1);
    keys2 = l10n_keys(file2);

    missing = missing_keys(keys1, keys2)
    if missing.length > 0 then
        print "Compare to '#{file1}', keys(#{missing.length}) missing in '#{file2}' listed as following:\n"
        missing.each do |key|
            print "#{key}\n"
        end
    end

    missing = missing_keys(keys2, keys1)
    if missing.length > 0 then
        print "Compare to '#{file2}', keys(#{missing.length}) missing in '#{file1}' listed as following:\n"
        missing.each do |key|
            print "#{key}\n"
        end
    end
end

def check_lproj_dir(dir1, dir2)
    Dir.foreach(dir1) do |file|
        file1 = dir1 + '/' + file
        file2 = dir2 + '/' + file
        if File.file?(file1) then
            if File.file?(file2) then
                check_l10n(file1, file2)
            else
                print "Directory '#{dir2}' missing file '#{file}'\n"
            end
        end
    end
end

if ARGV.length == 0 then
    usage
    exit 1
end

lprojDirs = Array.new
Dir.foreach(ARGV[0]) do |file|
    if file.end_with?(".lproj") and File.directory?(ARGV[0] + '/' + file) then
        lprojDirs.push(ARGV[0] + '/' + file)
    end
end

total = lprojDirs.length
(0..(total - 1)).each do |i|
    ((i  + 1)..(total - 1)).each do |j|
        check_lproj_dir(lprojDirs[i], lprojDirs[j])
        check_lproj_dir(lprojDirs[j], lprojDirs[i])
    end
end

