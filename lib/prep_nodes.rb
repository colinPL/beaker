def prep_nodes(config)
  usr_home=ENV['HOME']
  fail_flag=0
  master=""

  # Extract Master from config
  config.each_key do|host|
    config[host]['roles'].each do|role|
      if /master/ =~ role then        # If the host is puppet master
        master=host
      end
    end
  end

  # 1: SCP ptest/bin code to all nodes
	test_name="Copy remote executables to all hosts"
  config.each_key do|host|
	  BeginTest.new(host, test_name)
    scper = ScpFile.new(host)
    result = scper.do_scp("#{$work_dir}/ptest.tgz", "/")
    ChkResult.new(host, test_name, result.stdout, result.stderr, result.exit_code)
		fail_flag+=result.exit_code
  end

  # Execute remote command on each node, regardless of role
	test_name="Untar remote executables to all hosts"
  config.each_key do|host|
    BeginTest.new(host, test_name)
    runner = RemoteExec.new(host)
    result = runner.do_remote("cd / && tar xzf ptest.tgz")
    ChkResult.new(host, test_name, result.stdout, result.stderr, result.exit_code)
    fail_flag+=result.exit_code
  end

  # 1: SCP puppet code to master
	test_name="Copy Puppet code to Master"
	BeginTest.new(master, test_name)
  scper = ScpFile.new(master)
  result = scper.do_scp("#{$work_dir}/puppet.tgz", "/etc/puppetlabs")
  ChkResult.new(master, test_name, result.stdout, result.stderr, result.exit_code)
  fail_flag+=result.exit_code

  # Execute remote command  on each node, regardless of role
	test_name="Untar Puppet code on Master"
  BeginTest.new(master, test_name)
  runner = RemoteExec.new(master)
  result = runner.do_remote("cd /etc/puppetlabs && tar xzf puppet.tgz")
  ChkResult.new(master, test_name, result.stdout, result.stderr, result.exit_code)
  fail_flag+=result.exit_code

  return fail_flag

end
