# frozen_string_literal: true

require "mkmf"
require "debase/ruby_core_source"

if RUBY_VERSION < "2.6"
  STDERR.print("Ruby version must be 2.6 or older\n")
  exit(1)
end

hdrs = proc { have_header("vm_core.h") and have_header("iseq.h") }

if !Debase::RubyCoreSource::create_makefile_with_core(hdrs, "blab_trace")
  # error
  exit(1)
end
