//
//  CoreDataManager.swift
//  HabitTracker
//
//  Created by Diana Maldonado on 2025-12-10.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "HabitTracker")

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
            print("✅ Core Data loaded successfully")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data saved")
            } catch {
                print("❌ Error saving Core Data: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Clear All Data

    func clearAll() {
        let logFetch: NSFetchRequest<NSFetchRequestResult> = HabitLogEntity.fetchRequest()
        let habitFetch: NSFetchRequest<NSFetchRequestResult> = HabitEntity.fetchRequest()

        let logDelete = NSBatchDeleteRequest(fetchRequest: logFetch)
        let habitDelete = NSBatchDeleteRequest(fetchRequest: habitFetch)

        do {
            // Delete logs first to satisfy relationships if cascade isn't set
            try context.execute(logDelete)
            try context.execute(habitDelete)
            try context.save()
            print("🗑️ Cleared all Core Data (habits and logs)")
        } catch {
            print("❌ Error clearing Core Data: \(error.localizedDescription)")
        }
    }

    // MARK: - Habit Operations

    func createHabit(from habit: Habit) -> HabitEntity {
        let entity = HabitEntity(context: context)
        entity.id = habit.id
        entity.name = habit.name
        entity.descriptionText = habit.description
        entity.icon = habit.icon
        entity.color = habit.color
        entity.category = habit.category.rawValue
        entity.frequency = habit.frequency.rawValue
        entity.reminderTime = habit.reminderTime
        entity.reminderEnabled = habit.reminderEnabled
        entity.targetDays = habit.targetDays
        entity.timeOfDay = habit.timeOfDay?.rawValue
        entity.createdAt = habit.createdAt
        entity.goal = Int16(habit.goal)
        save()
        return entity
    }

    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]

        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                Habit(
                    id: entity.id ?? UUID(),
                    name: entity.name ?? "",
                    description: entity.descriptionText ?? "",
                    icon: entity.icon ?? "⭐️",
                    color: entity.color ?? "purple",
                    category: HabitCategory(rawValue: entity.category ?? "") ?? .other,
                    frequency: HabitFrequency(rawValue: entity.frequency ?? "") ?? .daily,
                    reminderTime: entity.reminderTime,
                    reminderEnabled: entity.reminderEnabled,
                    targetDays: entity.targetDays ?? [0, 1, 2, 3, 4, 5, 6],
                    createdAt: entity.createdAt ?? Date(),
                    goal: Int(entity.goal),
                    timeOfDay: entity.timeOfDay != nil ? TimeOfDay(rawValue: entity.timeOfDay!) : nil
                )
            }
        } catch {
            print("❌ Error fetching habits: \(error)")
            return []
        }
    }

    func updateHabit(_ habit: Habit) {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)

        do {
            let entities = try context.fetch(request)
            if let entity = entities.first {
                entity.name = habit.name
                entity.descriptionText = habit.description
                entity.icon = habit.icon
                entity.color = habit.color
                entity.category = habit.category.rawValue
                entity.frequency = habit.frequency.rawValue
                entity.reminderTime = habit.reminderTime
                entity.reminderEnabled = habit.reminderEnabled
                entity.targetDays = habit.targetDays
                entity.timeOfDay = habit.timeOfDay?.rawValue
                entity.goal = Int16(habit.goal)
                save()
            }
        } catch {
            print("❌ Error updating habit: \(error)")
        }
    }

    func deleteHabit(_ habit: Habit) {
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habit.id as CVarArg)

        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            save()
        } catch {
            print("❌ Error deleting habit: \(error)")
        }
    }

    // MARK: - Log Operations

    func createLog(habitId: UUID, date: Date, completed: Bool = true, note: String? = nil) {
        // Check if log already exists for this date
        let request: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habit.id == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg,
            date.startOfDay as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: date.startOfDay)! as CVarArg
        )

        do {
            let existing = try context.fetch(request)
            if !existing.isEmpty {
                print("⚠️ Log already exists for this date")
                return
            }

            // Fetch the habit entity
            let habitRequest: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
            habitRequest.predicate = NSPredicate(format: "id == %@", habitId as CVarArg)
            let habits = try context.fetch(habitRequest)

            if let habitEntity = habits.first {
                let logEntity = HabitLogEntity(context: context)
                logEntity.id = UUID()
                logEntity.date = date.startOfDay
                logEntity.completed = completed
                logEntity.note = note
                logEntity.habit = habitEntity
                save()
            }
        } catch {
            print("❌ Error creating log: \(error)")
        }
    }

    func deleteLog(habitId: UUID, date: Date) {
        let request: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habit.id == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg,
            date.startOfDay as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: date.startOfDay)! as CVarArg
        )

        do {
            let logs = try context.fetch(request)
            logs.forEach { context.delete($0) }
            save()
        } catch {
            print("❌ Error deleting log: \(error)")
        }
    }

    func fetchLogs(for habitId: UUID? = nil) -> [HabitLog] {
        let request: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()

        if let habitId = habitId {
            request.predicate = NSPredicate(format: "habit.id == %@", habitId as CVarArg)
        }

        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let habitId = entity.habit?.id else { return nil }
                return HabitLog(
                    id: entity.id ?? UUID(),
                    habitId: habitId,
                    date: entity.date ?? Date(),
                    completed: entity.completed,
                    note: entity.note
                )
            }
        } catch {
            print("❌ Error fetching logs: \(error)")
            return []
        }
    }

    func isHabitCompleted(habitId: UUID, on date: Date) -> Bool {
        let request: NSFetchRequest<HabitLogEntity> = HabitLogEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "habit.id == %@ AND date >= %@ AND date < %@",
            habitId as CVarArg,
            date.startOfDay as CVarArg,
            Calendar.current.date(byAdding: .day, value: 1, to: date.startOfDay)! as CVarArg
        )

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
}
