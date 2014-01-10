package
{
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	
	public class testmesh extends Mesh
	{
		public function testmesh(geometry:Geometry, material:MaterialBase=null)
		{
			super(geometry, material);
		}
	}
}