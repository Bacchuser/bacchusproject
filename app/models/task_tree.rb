class TaskTree < ActiveRecord::Base
  #
  # Remove recursively all the childs.
  # Update all the tree to close the gap
  #
  before_destroy do |perm|
    TaskTree.transaction do
      # Delete
      childs_and_me = TaskTree.where("left_tree >= :left_tree AND right_tree <= :right_tree", { left_tree: left_tree, right_tree: right_tree } )
      childs_and_me.delete_all

      # Update tree
      right_part = TaskTree.where("right_tree >= :left_tree", { left_tree: left_tree } )
      left_part = TaskTree.where("left_tree > :left_tree", { left_tree: left_tree } )

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
          right_update = TaskTree.where("right_tree >= :right_tree", { right_tree: right_tree } )
          right_update.update_all("right_tree = right_tree + 2")

          left_update = TaskTree.where("left_tree >= :right_tree", { right_tree: right_tree } )
          left_update.update_all("left_tree = left_tree + 2")

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
        .where("right_tree > :child_right_tree AND left_tree < :child_left_tree AND tree_level = :tree_level", \
          { child_right_tree: right_tree,
            child_left_tree: left_tree,
            tree_level: tree_level - 1 } ).first
    end
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
end
