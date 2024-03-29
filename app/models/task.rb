# A generic n-ary tree, You can add childs, remove a node and it's child,
# and get some properties such as level, type(node, leaf).
class Task < ActiveRecord::Base
  SUBTASK_CLASSES = {}
  [SimpleTask, ListTask, ListTaskItem].each do |class_var|
    SUBTASK_CLASSES[class_var.model_name.singular] = class_var
  end

  #
  # Remove recursively all the childs.
  # Update all the tree to close the gap
  #
  before_destroy do |perm|
    Task.transaction do
      # Delete
      childs_and_me = Task.where("""
        event_id = :event_id
        AND left_tree >= :left_tree
        AND right_tree <= :right_tree """,
        { event_id: self.id, left_tree: self.left_tree, right_tree: self.right_tree } )
      childs_and_me.delete_all

      # Update tree
      right_part = Task.where("""
        event_id = :event_id
        AND right_tree >= :left_tree """,
        { event_id: self.event_id, left_tree: self.left_tree } )
      left_part = Task.where("""
        event_id = :event_id
        AND left_tree > :left_tree """, { event_id: id, left_tree: left_tree } )

      offset = self.right_tree - self.left_tree + 1
      right_part.update_all(["right_tree = right_tree - :offset", { offset: offset } ])
      left_part.update_all(["left_tree = left_tree - :offset", { offset: offset } ])
    end
  end

  def self.new_for_event(event)
    last_created = Task.where("event_id = :event_id ", { event_id: event.id } )
    new_task = event.task.new_child
    new_task.is_visible = false
    new_task.label = "New task #" + last_created.count.to_s
    return new_task
  end

  def new?
    subtask.nil?
  end

  def is_subtask?
    false
  end

  def has_subtask?
    not self.subtask.nil?
  end

  def subtask
    return nil if self.subtask_name.nil?

    unless Task::SUBTASK_CLASSES.has_key? self.subtask_name
      raise "Subtask " + self.subtask_name + " not allowed"
    end
    if @task_subtask.nil?
      @task_subtask = Task::SUBTASK_CLASSES[self.subtask_name].where("id = :id", { id: self.subtask_id }).first
    else
      @task_subtask
    end
  end

  #
  # Add a child to the current leaf/node.
  # Return the new child created.
  #
  def new_child
    if self.right_tree.nil? or self.left_tree.nil? or self.event_id.nil?
      raise "Tree corrupted : parent not exists\n" + inspect
    end

    right_tree = self.right_tree
    event_id = self.event_id
    new_task = Task.new do |task|
      task.left_tree = right_tree
      task.right_tree = right_tree + 1
      task.tree_level = self.tree_level + 1
      task.event_id = event_id
    end

    Task.transaction do
      # create an empty space in the tree
      right_update = Task.where("""
        event_id = :event_id
        AND right_tree >= :right_tree """, { event_id: event_id, right_tree: right_tree } )
      right_update.update_all "right_tree = right_tree + 2"

      left_update = Task.where("""
        event_id = :event_id
        AND left_tree >= :right_tree """, { event_id: event_id, right_tree: right_tree } )
      left_update.update_all "left_tree = left_tree + 2"

      new_task.save!
    end

    self.reload
    return new_task
  end

  #
  # Return the direct parent for this task_tree
  #
  def get_parent
    if tree_level == 0
      nil
    else
      Task \
        .where("""
          event_id = :event_id
          AND right_tree > :child_right_tree
          AND left_tree < :child_left_tree
          AND tree_level = :tree_level """,
          { event_id: event_id,
            child_right_tree: right_tree,
            child_left_tree: left_tree,
            tree_level: tree_level - 1 } ).first
    end
  end

  def children
    result = Task.where("""
      event_id = :event_id
      AND right_tree < :right_tree
      AND left_tree > :left_tree """,
      { event_id: self.event_id,
        right_tree: self.right_tree,
        left_tree: self.left_tree,
        tree_level: self.tree_level + 1 })

    return result
  end

  #
  # Create a root for a new task, with a incremented event_id.
  # The model is not saved in DB. Please use the .save() method
  # whenever you want to insert it in DB.
  #
  def root_for_event! (event)
    if event.nil? or event.id.nil?
      raise "Event ID is null !"
    end

    self.tree_level = 1
    self.left_tree = 1
    self.right_tree = 2
  end

  #
  # Self explanatory
  #
  def self.find_task_tree(node_label)
    left_tree_pos = get_node_pos(label)
    #TODO return the instance with the left_tree_pos
  end

  #
  # Self explanatory
  #
  def leaf?
    # Left and Right continuous ?
    return (right_tree - left_tree == 1)
  end

  #
  # Get if the label is in the node/leaf or
  # in the label of childs. Looks recursively in all
  # the childs subtrees.
  #
  def is_child? (node_label)
    # Get the position in adjacent interval of the label given
    position = get_node_pos(node_label)
    # Check if the position is between left and right bounds
    return (position >= left_tree and position <= right_tree)
  end

  private
  #
  # Get the node position in the adjacent interval
  # implemention of the label given.
  #
  def get_node_pos(node_label)
    left_tree
  end
end