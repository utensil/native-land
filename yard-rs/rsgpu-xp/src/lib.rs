pub mod compute;

use std::borrow::Cow;

struct CompiledShaderModules {
    named_spv_modules: Vec<(Option<String>, wgpu::ShaderModuleDescriptorSpirV<'static>)>,
}

impl CompiledShaderModules {
    fn spv_module_for_entry_point<'a>(
        &'a self,
        wanted_entry: &str,
    ) -> wgpu::ShaderModuleDescriptorSpirV<'a> {
        for (name, spv_module) in &self.named_spv_modules {
            match name {
                Some(name) if name != wanted_entry => continue,
                _ => {
                    return wgpu::ShaderModuleDescriptorSpirV {
                        label: name.as_deref(),
                        source: Cow::Borrowed(&spv_module.source),
                    };
                }
            }
        }
        unreachable!(
            "{wanted_entry:?} not found in modules {:?}",
            self.named_spv_modules
                .iter()
                .map(|(name, _)| name)
                .collect::<Vec<_>>()
        );
    }
}
