require 'travis/api/serialize/formats'

module Travis
  module Api
    module Serialize
      module V2
        module Http
          class Job
            include Formats

            attr_reader :job, :params
            attr_accessor :options

            def initialize(job, params = {})
              @job = job
              @params = params
              @options = {}
            end

            def data
              Travis.logger.debug("#{self.class.name} params=#{params.inspect} options=#{options.inspect}")
              {
                'job' => job_data(job),
                'commit' => commit_data(job.commit, job.repository),
                'annotations' => Annotations.new(job.annotations, @options).data["annotations"]
              }
            end

            private

              def job_data(job)
                {
                  'id' => job.id,
                  'repository_id' => job.repository_id,
                  'repository_slug' => job.repository.slug,
                  'build_id' => job.source_id,
                  'commit_id' => job.commit_id,
                  'number' => job.number,
                  'config' => job.obfuscated_config.stringify_keys,
                  'state' => job.state.to_s,
                  'started_at' => format_date(job.started_at),
                  'finished_at' => format_date(job.finished_at),
                  'queue' => job.queue,
                  'allow_failure' => job.allow_failure,
                  'tags' => job.tags,
                  'annotation_ids' => job.annotation_ids,
                }.tap do |ret|
                  ret['log_id'] = job.log_id if include_log_id?
                end
              end

              def commit_data(commit, repository)
                {
                  'id' => commit.id,
                  'sha' => commit.commit,
                  'branch' => commit.branch,
                  'branch_is_default' => branch_is_default(commit, repository),
                  'message' => commit.message,
                  'committed_at' => format_date(commit.committed_at),
                  'author_name' => commit.author_name,
                  'author_email' => commit.author_email,
                  'committer_name' => commit.committer_name,
                  'committer_email' => commit.committer_email,
                  'compare_url' => commit.compare_url,
                }
              end

              def branch_is_default(commit, repository)
                repository.default_branch == commit.branch
              end

              def include_log_id?
                !!options[:include_log_id]
              end
          end
        end
      end
    end
  end
end
