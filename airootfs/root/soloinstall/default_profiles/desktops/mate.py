from typing import override

from soloinstall.default_profiles.profile import GreeterType, ProfileType
from soloinstall.default_profiles.xorg import XorgProfile


class MateProfile(XorgProfile):
	def __init__(self) -> None:
		super().__init__('Mate', ProfileType.DesktopEnv)

	@property
	@override
	def packages(self) -> list[str]:
		return [
			'mate',
			'mate-extra',
		]

	@property
	@override
	def default_greeter_type(self) -> GreeterType:
		return GreeterType.Lightdm
