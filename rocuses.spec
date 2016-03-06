%global prefix /usr
%global ruby_major_version 1
%global ruby_minor_version 8
%global ruby_patch_level 0
%global ruby_version %{ruby_major_version}.%{ruby_minor_version}.%{ruby_patch_level}
%global gemdir %{prefix}/lib/ruby/gems/%{ruby_major_version}.%{ruby_minor_version}
%global gem %{prefix}/bin/gem
%global major_version 0
%global minor_version 0
%global patch_level 1

%global log4r_version 1.1.10

%undefine __arch_install_post

Name:		rocuses
Version:	%{major_version}.%{minor_version}.%{patch_level}
Release:	1%{?dist}
Summary:	Monitoring Server systems.

Group:		Development/Tools
License:	MIT
URL:		https://github.com/siskrn/rocuses/
Source0:	log4r-%{log4r_version}.gem
Source1:	rocuses-%{version}.gem

BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)


%global		gem_install %{gem} install -V --local --bindir %{buildroot}%{prefix}/bin --install-dir %{buildroot}%{gemdir} --force --rdoc

BuildRequires:	ruby
BuildRequires:	rubygems
BuildRequires:	rubygem-net-ldap
BuildRequires:	rubygem-flexmock
BuildRequires:	rubygem-rake
BuildRequires:	rubygem-bundler
Requires:	ruby
Requires:	rubygems
Requires:	rubygem-net-ldap
Requires:       chkconfig

%description
Server Montoring tool.


%prep

%build

%install
mkdir -p %{buildroot}%{gemdir}

%{gem_install} %{SOURCE0}
%{gem_install} %{SOURCE1}


mkdir -p %{buildroot}/etc/rocuses
mkdir -p %{buildroot}/etc/init.d
mkdir -p %{buildroot}/var/log/rocus
mkdir -p %{buildroot}/var/log/rocuses
mkdir -p %{buildroot}/etc/rocuses
mkdir -p %{buildroot}/var/lib/rocuses

cp %{buildroot}%{gemdir}/gems/rocuses-%{version}/conf/rocuses/agentconfig.sample.xml   %{buildroot}/etc/rocuses
cp %{buildroot}%{gemdir}/gems/rocuses-%{version}/conf/rocuses/log4r.sample.xml         %{buildroot}/etc/rocuses
cp %{buildroot}%{gemdir}/gems/rocuses-%{version}/conf/rocuses/managerconfig.sample.xml %{buildroot}/etc/rocuses
cp %{buildroot}%{gemdir}/gems/rocuses-%{version}/conf/rocuses/targetsconfig.sample.xml %{buildroot}/etc/rocuses

cp %{buildroot}%{gemdir}/gems/rocuses-%{version}/data/rocuses/init.d/rocusagent   %{buildroot}/etc/init.d

%pre

if ! getent group rocus
then
    groupadd rocus
fi

if ! getent passwd rocus
then
    useradd -g rocus -s /bin/false rocus
fi

if ! getent group rocuses
then
    groupadd rocuses
fi

if ! getent passwd rocuses
then
    useradd -g rocuses rocuses
fi

%post

chkconfig --add rocusagent

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)


/usr/lib/ruby/gems/1.8/gems/log4r-%{log4r_version}/
/usr/lib/ruby/gems/1.8/gems/rocuses-%{version}/
/usr/lib/ruby/gems/1.8/specifications/log4r-%{log4r_version}.gemspec
/usr/lib/ruby/gems/1.8/specifications/rocuses-%{version}.gemspec
/usr/lib/ruby/gems/1.8/cache/log4r-%{log4r_version}.gem
/usr/lib/ruby/gems/1.8/cache/rocuses-%{version}.gem
/etc/rocuses/

%attr(0755,root,root) /usr/bin/rocusagent.rb
%attr(0755,root,root) /usr/bin/rocusesmanager.rb

%attr(0744,root,root) /etc/init.d/rocusagent

%attr(0755,rocus,rocus) /var/log/rocus
%attr(0755,rocuses,rocuses) /var/log/rocuses

%doc
%defattr(-,root,root,-)
/usr/lib/ruby/gems/1.8/doc/log4r-%{log4r_version}/
/usr/lib/ruby/gems/1.8/doc/rocuses-%{version}/

%changelog

