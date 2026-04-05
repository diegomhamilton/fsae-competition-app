# Architecture Reference

Code patterns and source layout for the current project. Used by `ios-scaffold`.

## Source layout

```
FSAEInspectionChecklist/FSAEInspectionChecklist/
├── Models/
├── Services/
├── ViewModels/
└── UI/
    ├── Screens/
    └── Components/
```

## File naming convention

| Layer | Path pattern | Example |
|---|---|---|
| Model | `Models/{Entity}.swift` | `Models/Checklist.swift` |
| Service | `Services/{Entity}Service.swift` | `Services/ChecklistService.swift` |
| ViewModel (List) | `ViewModels/{Entity}ListViewModel.swift` | `ViewModels/ChecklistListViewModel.swift` |
| ViewModel (Detail) | `ViewModels/{Entity}DetailViewModel.swift` | `ViewModels/ChecklistDetailViewModel.swift` |
| Screen (List) | `UI/Screens/{Entity}ListView.swift` | `UI/Screens/ChecklistListView.swift` |
| Screen (Detail) | `UI/Screens/{Entity}DetailView.swift` | `UI/Screens/ChecklistDetailView.swift` |
| Row Component | `UI/Components/{Entity}RowView.swift` | `UI/Components/ChecklistRowView.swift` |

## Model

```swift
import Foundation
import SwiftData

@Model
final class {Entity} {
    // user-confirmed properties
    var createdAt: Date

    init(...) {
        self.createdAt = Date()
    }
}
```

Parent–child relationship (cascade delete):
```swift
@Relationship(deleteRule: .cascade) var items: [{Child}] = []
```

## Service

```swift
import Foundation
import SwiftData

final class {Entity}Service {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [{Entity}] {
        let descriptor = FetchDescriptor<{Entity}>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    @discardableResult
    func create(...) throws -> {Entity} {
        let entity = {Entity}(...)
        modelContext.insert(entity)
        try modelContext.save()
        return entity
    }

    func delete(_ entity: {Entity}) throws {
        modelContext.delete(entity)
        try modelContext.save()
    }
}
```

## ViewModel (List)

```swift
import Foundation

@Observable
final class {Entity}ListViewModel {
    var errorMessage: String?
    private var service: {Entity}Service?

    func configure(with service: {Entity}Service) {
        self.service = service
    }

    func create(...) {
        do { try service?.create(...) }
        catch { errorMessage = error.localizedDescription }
    }

    func delete(_ entity: {Entity}) {
        do { try service?.delete(entity) }
        catch { errorMessage = error.localizedDescription }
    }
}
```

## ViewModel (Detail)

```swift
import Foundation

@Observable
final class {Entity}DetailViewModel {
    let entity: {Entity}
    var errorMessage: String?
    private var service: {Entity}Service?

    init(entity: {Entity}) { self.entity = entity }

    func configure(with service: {Entity}Service) {
        self.service = service
    }
}
```

## Screen (List)

```swift
import SwiftUI
import SwiftData

struct {Entity}ListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \{Entity}.createdAt, order: .reverse) private var items: [{Entity}]
    @State private var viewModel = {Entity}ListViewModel()
    @State private var isAdding = false
    @State private var newTitle = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        {Entity}RowView(entity: item)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet { viewModel.delete(items[index]) }
                }
            }
            .navigationTitle("{Entity Plural}")
            .navigationDestination(for: {Entity}.self) { item in
                {Entity}DetailView(entity: item)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") { isAdding = true }
                }
            }
            .alert("New {Entity}", isPresented: $isAdding) {
                TextField("Title", text: $newTitle)
                Button("Create") {
                    let t = newTitle.trimmingCharacters(in: .whitespaces)
                    guard !t.isEmpty else { return }
                    viewModel.create(title: t)
                    newTitle = ""
                }
                Button("Cancel", role: .cancel) { newTitle = "" }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            viewModel.configure(with: {Entity}Service(modelContext: modelContext))
        }
    }
}
```

## Screen (Detail)

```swift
import SwiftUI
import SwiftData

struct {Entity}DetailView: View {
    @Environment(\.modelContext) private var modelContext
    let entity: {Entity}
    @State private var viewModel: {Entity}DetailViewModel

    init(entity: {Entity}) {
        self.entity = entity
        _viewModel = State(wrappedValue: {Entity}DetailViewModel(entity: entity))
    }

    var body: some View {
        // layout based on confirmed entity properties
        .navigationTitle(entity.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.configure(with: {Entity}Service(modelContext: modelContext))
        }
    }
}
```

## Row Component

```swift
import SwiftUI

struct {Entity}RowView: View {
    let entity: {Entity}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entity.title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        // derive from entity properties
        ""
    }
}
```

## App entry point — model registration

`FSAEInspectionChecklistApp.swift` — add new model to `Schema`:

```swift
let schema = Schema([
    Checklist.self,
    ChecklistItem.self,
    {Entity}.self,  // add here
])
```
