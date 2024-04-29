extends Node

signal progress_button_hover(resource_generator: ResourceGenerator)
signal progress_button_pressed(resource_generator: ResourceGenerator)
signal progress_button_paid(resource_generator: ResourceGenerator)
signal progress_button_unpaid(resource_generator: ResourceGenerator)

signal resource_updated(id: String, total: int, amount: int)

signal manager_button_hover(worker_role: WorkerRole)
signal manager_button_add(worker_role: WorkerRole)
signal manager_button_del(worker_role: WorkerRole)

signal worker_updated(id: String, total: int, amount: int)
signal worker_efficiency_updated(efficiencies: Dictionary)

signal event_triggered(id: String, args: Dictionary)
signal event_saved(content: String, index: int)
