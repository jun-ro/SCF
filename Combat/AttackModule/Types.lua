local module = {}

export type AttackData = {
	AttackType: string,
	Animation: string,
	EnemyAnim: string,
	PushbackMagnitude: number,
	Hitbox: Vector3,
	Damage: number
}

return module
