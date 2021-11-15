/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import ComposableArchitecture

struct RootState {
  var userState: UserState = UserState()
  var repositoryState: RepositoryState = RepositoryState()
}

enum RootAction {
  case userAction(UserAction)
  case repositoryAction(RepositoryAction)
}

struct RootEnvironment { }

let rootReducer = Reducer<RootState, RootAction, SystemEnvironment<RootEnvironment>>.combine(
  // pullback transforms repositoryReducer to work on RootState, RootAction and RootEnvironment.
  userReducer.pullback(
    // repositoryReducer works on the local RepositoryState. You use a a key path to plug out the local state from the global RootState.
    state: \.userState,
    // A case path makes the local RepositoryAction accessible from the global RootAction
    action: /RootAction.userAction,
    environment: { _ in .live(environment: UserEnvironment(userRequest: userEffect)) }
  ),
  repositoryReducer.pullback(
    state: \.repositoryState,
    action: /RootAction.repositoryAction,
    environment: { _ in
        .live(environment: RepositoryEnvironment(repositoryRequest: repositoryEffect))
    }
  ),
  Reducer { state, action, environment in
    switch action {
    case .userAction(let action):
      debugPrint(".userAction executed with \(action)")
      return .none
      
//    case .repositoryAction(let action):
    case .repositoryAction(.favoriteButtonTapped(_)):
      debugPrint("Favorite button was tapped on RepositoryView cell")
      return .none
      
    case .repositoryAction(.onAppear):
      debugPrint("RepositoryListView has appeared")
      return .none
      
    case .repositoryAction(.dataLoaded(let result)):
      debugPrint("Effect has fetched request and decoded result")
      debugPrint("FIRST ELEMENT FROM REPO LIST IS \(state.repositoryState.repositories.first?.name ?? "")")
      //or
//      switch result {
//      case .success(let repositories):
//        debugPrint("FIRST ELEMENT FROM REPO LIST IS \(repositories.first?.name ?? "")")
//      case .failure:
//        break
//      }
      return .none
    }
  }
)
