#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: couchdb
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "erlang"

package "couchdb" do
  package_name value_for_platform(
    "openbsd" => { "default" => "apache-couchdb" },
    "gentoo" => { "default" => "dev-db/couchdb" },
    "default" => "couchdb"
  )
end

template "couchdb/local.ini" do
  owner "couchdb"
  group "couchdb"
  mode 0664
  path "/etc/couchdb/local.ini"
  source "local.ini.erb"
end

directory "/var/lib/couchdb" do
  owner "couchdb"
  group "couchdb"
  recursive true
  path value_for_platform(
    "openbsd" => { "default" => "/var/couchdb" },
    "freebsd" => { "default" => "/var/couchdb" },
    "gentoo" => { "default" => "/var/couchdb" },
    "default" => "/var/lib/couchdb"
  )
end

# shutdown the couch started by couchdb packaage
execute "shutdown-couch" do
  command "killall couchdb; killall beam; sleep 3"
end

service "couchdb" do
  if platform?("centos","redhat","fedora")
    start_command "/sbin/service couchdb start &> /dev/null"
    stop_command "/sbin/service couchdb stop &> /dev/null"
  end
  # the couchdb service doesn't appear to handle restart or status
  action [ :enable, :start ]
end