enum MainViewStateType: Equatable {
    case final
    case isLoading
    case loaded(items: [MainViewSectionType: [MainRegularItem]])
}
