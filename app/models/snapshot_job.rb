class SnapshotJob < Struct.new(:name)
  # Custom DelayedJobs much implement the perform method
  def perform
    # Expensive system call (creates a shell and execute a command)
    #exit_code = %x(/usr/games/fortune)
    #Snapshot.create!(text: text)
  end
end