# A generic n-ary tree, You can add childs, remove a node and it's child,
# and get some properties such as level, type(node, leaf).
class TaskTree < ActiveRecord::Base

  #
  # Remove recursively all the childs.
  # Update all the tree to close the gap
  #
  before_destroy do |perm|
    TaskTree.transaction do
      # Delete
      childs_and_me = TaskTree.where("event_id = :event_id AND left_tree >= :left_tree AND right_tree <= :right_tree", { event_id: event_id, left_tree: left_tree, right_tree: right_tree } )
      childs_and_me.delete_all

      # Update tree
      right_part = TaskTree.where("event_id = :event_id AND right_tree >= :left_tree", { event_id: event_id, left_tree: left_tree } )
      left_part = TaskTree.where("event_id = :event_id AND left_tree > :left_tree", { event_id: event_id, left_tree: left_tree } )

      offset = right_tree - left_tree + 1
      right_part.update_all("right_tree = right_tree - :offset", { :offset => offset } )
      left_part.update_all("left_tree = left_tree - :offset", { :offset => offset } )
    end
  end


  #
  # Add a child to the current leaf/node.
  # Return the new child created.
  #
  def add_child(node_label, description)
      TaskTree.transaction do
          # create an empty space in the tree
          right_update = TaskTree.where("event_id = :event_id AND right_tree >= :right_tree", { event_id: event_id, right_tree: right_tree } )
          right_update.update_all("event_id = :event_id AND right_tree = right_tree + 2", { event_id: event_id })

          left_update = TaskTree.where("event_id = :event_id AND left_tree >= :right_tree", { event_id: event_id, right_tree: right_tree } )
          left_update.update_all("event_id = :event_id AND left_tree = left_tree + 2", { event_id: event_id })

          new_task_tree = TaskTree.new do |task_tree|
            task_tree.left_tree = right_tree
            task_tree.right_tree = right_tree + 1
            task_tree.tree_level = tree_level + 1

            task_tree.label = node_label
          end

          new_task_tree.save!
          reload
          return(new_task_tree)
      end
  end

  #
  # Return the direct parent for this task_tree
  #
  def get_parent
    if tree_level == 0
      nil
    else
      TaskTree \
        .where("event_id = :event_id AND right_tree > :child_right_tree AND left_tree < :child_left_tree AND tree_level = :tree_level", \
          { event_id: event_id,
            child_right_tree: right_tree,
            child_left_tree: left_tree,
            tree_level: tree_level - 1 } ).first
    end
  end

  #
  # Create a root for a new task, with a incremented event_id.
  # The model is not saved in DB. Please use the .save() method
  # whenever you want to insert it in DB.
  #
  def self.new_root
      new_tree = TaskTree.new
      new_tree.event_id = new_event_id
      return new_tree
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
  def is_leaf?
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

  #
  # Get a new ID for a new tree.
  #
  def self.new_event_id
    # create a new event in the task_tree, with a new event id
    temp = TaskTree.order("event_id desc").limit(1).first
    if temp.nil?
      1
    else
      temp.event_id + 1
    end
  end

end
