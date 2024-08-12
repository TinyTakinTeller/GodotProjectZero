class_name AutoMason
extends Node

const MAX_N: int = 250

var h_total: int
var h_extra: int
var m_total: int
var c_pph: int
var c_req: int
var p_now: int
var p_extra: int
var p_leftover: int
var sergeants: int
var shadow_percent: int


## Cursed variable names? Say something, I'm giving up on you...
func clear_cache(h: int, m: int, a: int, b: int, p: int, s: int, w: int) -> void:
	h_total = h
	h_extra = 0
	m_total = m
	c_pph = a
	c_req = b
	p_now = p
	p_extra = 0
	p_leftover = 0
	sergeants = s
	shadow_percent = w


func cycles(n: int) -> Dictionary:
	var i: int = 0
	while i <= n:
		i += 1
		_cycle()
		if (
			h_total >= Limits.GLOBAL_MAX_AMOUNT
			or m_total >= Limits.GLOBAL_MAX_AMOUNT
			or p_now + p_extra >= Limits.GLOBAL_MAX_AMOUNT
		):
			break
	return {"n": i, "h": h_extra, "p": p_extra, "m_total": m_total}


func _cycle() -> void:
	# calc p_new
	var p_max: int = Limits.safe_mult(c_pph, h_total)
	var p_curr: int = p_now + p_extra
	var p_new: int = ((p_max - p_curr - 1) / c_pph) + 1
	p_new = max(0, p_new - sergeants)
	p_extra += p_new
	# calc p_mason
	p_leftover += p_new
	var p_mason: int = p_leftover / c_req
	var p_reqs: int = Limits.safe_mult(p_mason, c_req)
	if p_reqs >= Limits.GLOBAL_MAX_AMOUNT:
		p_mason = p_reqs / c_req
	p_leftover = max(0, p_leftover - p_reqs)
	# calc iter
	m_total += p_mason
	var new_h: int = m_total
	new_h = SaveFile.scale_by_shadows("house", new_h, shadow_percent)
	h_total += m_total
	h_extra += m_total
