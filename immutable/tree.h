///
/// \file array.h
///

#pragma once

#include "base.h"

NAMESPACE_IMMUTABLE_START

// Persistent array (aka vector aka random-access list)
template <typename T>
struct Tree : RefCounted {
  /// The contained type as a Value
  using ValueT = Value<T>;

  /// Interal Iterator
  struct Iterator;

  /// Return the empty tree
  static ref<Tree> empty();

  /// Create a tree from an initializer list
  template <typename Y> static ref<Tree> create(std::initializer_list<Y>&&);

  /// Copy constructor
  Tree(const Tree &) = default;

  protected:
    friend struct TreeImp;

    Tree() = delete;
    void dealloc() { delete this; }


    IMMUTABLE_REFCOUNTED_IMPL(Tree)
};


NAMESPACE_IMMUTABLE_END
